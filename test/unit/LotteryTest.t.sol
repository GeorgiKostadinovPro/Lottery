// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {Vm} from "../../lib/forge-std/src/Vm.sol";
import {Lottery} from "../../src/Lottery.sol";
import {DeployLottery} from "../../script/DeployLottery.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract LotteryTest is Test {
    uint256 private constant STARTING_USER_BALANCE = 10 ether;
    address private USER = makeAddr("User");

    Lottery private lottery;
    HelperConfig private helperConfig;

    uint256 private entrancePrice;
    uint256 private lotteryDuration;
    address private vrfCoordinator;
    bytes32 private keyHash;
    uint256 private subscriptionId;
    uint32 private callbackGasLimit;

    event EnterLottery(address indexed participant);
    event ChosenWinner(address indexed winner);

    modifier enterLottery() {
        vm.prank(USER);
        lottery.enterLottery{value: entrancePrice}();
        vm.warp(block.timestamp + lotteryDuration + 1);
        vm.roll(block.number + 1);
        _;
    }

    function setUp() external {
        DeployLottery deployer = new DeployLottery();
        (lottery, helperConfig) = deployer.deployLottery();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entrancePrice = config.entrancePrice;
        lotteryDuration = config.lotteryDuration;
        vrfCoordinator = config.vrfCoordinator;
        keyHash = config.keyHash;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;

        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testLotteryStartAsOpen() public view {
        assert(lottery.getLotteryState() == Lottery.LotteryState.OPEN);
    }

    function testEnterLotteryRevertsWhenNotEnoughEth() public {
        vm.prank(USER);
        vm.expectRevert(Lottery.Lottery__NotEnoughEthToEnterLottery.selector);
        lottery.enterLottery();
    }

    function testEnterLotteryWhenOpen() public {
        vm.prank(USER);
        lottery.enterLottery{value: entrancePrice}();

        assert(lottery.getParticipants().length == 1);
    }

    function testEmitEventAfterEnteringLottery() public {
        vm.prank(USER);
        vm.expectEmit(true, false, false, false, address(lottery));
        emit EnterLottery(USER);
        lottery.enterLottery{value: entrancePrice}();
    }

    function testDontAllowUsersToEnterWhileLotteryIsChoosingWinner() public {
        vm.prank(USER);
        lottery.enterLottery{value: entrancePrice}();
        vm.warp(block.timestamp + lotteryDuration + 1);
        vm.roll(block.number + 1);
        lottery.performUpkeep("");

        vm.prank(USER);
        vm.expectRevert(Lottery.Lottery__ChoosingWinner.selector);
        lottery.enterLottery{value: entrancePrice}();
    }

    function testCheckUpkeepReturnsFalseWhenItHasNoBalance() public {
        vm.warp(block.timestamp + lotteryDuration + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = lottery.checkUpkeep("");

        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsFalseWhenItIsNotOpen() public enterLottery {
        lottery.performUpkeep("");

        (bool upkeepNeeded, ) = lottery.checkUpkeep("");

        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsTrueWhenValid() public enterLottery {
        (bool upkeepNeeded, ) = lottery.checkUpkeep("");

        assert(upkeepNeeded);
    }

    function testPerformUpkeepThrowsWhenUpkeepNeededIsFalse() public {
        vm.warp(block.timestamp + lotteryDuration + 1);
        vm.roll(block.number + 1);

        vm.expectRevert(Lottery.Lottery__NotValidCheckUpkeep.selector);
        lottery.performUpkeep("");
    }

    function testPerformUpkeepIsCalledOnlyWhenCheckUpkeepIsTrue()
        public
        enterLottery
    {
        lottery.performUpkeep("");
    }

    function testPerformUpkeepChangesLotteryStateWhenValid()
        public
        enterLottery
    {
        lottery.performUpkeep("");

        assert(
            lottery.getLotteryState() == Lottery.LotteryState.CHOOSING_WINNER
        );
    }

    function testFulfillRandomWorldsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 _randomRequestId
    ) public enterLottery {
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            _randomRequestId,
            address(lottery)
        );
    }

    function testFulfillRandomWordsPicksAWinnerResetsAndSendsReward()
        public
        enterLottery
    {
        address expectedWinner = address(1);
        uint256 moreParticipants = 3;
        uint256 startIdx = 1;

        for (uint256 i = startIdx; i < startIdx + moreParticipants; i++) {
            address participant = address(uint160(i));
            hoax(participant, 1 ether);
            lottery.enterLottery{value: entrancePrice}();
        }

        uint256 startingTimeStamp = lottery.getLastTimeWinnerPicked();
        uint256 startingBalance = expectedWinner.balance;

        vm.recordLogs();
        lottery.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(lottery)
        );

        address recentWinner = lottery.getRecentWinner();
        Lottery.LotteryState lotteryState = lottery.getLotteryState();
        uint256 winnerBalance = recentWinner.balance;
        uint256 endingTimeStamp = lottery.getLastTimeWinnerPicked();
        uint256 reward = entrancePrice * (moreParticipants + 1);

        assert(recentWinner == expectedWinner);
        assert(uint256(lotteryState) == 0);
        assert(winnerBalance == startingBalance + reward);
        assert(endingTimeStamp > startingTimeStamp);
    }
}
