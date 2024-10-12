// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {Lottery} from "../../src/Lottery.sol";
import {DeployLottery} from "../../script/DeployLottery.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

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
}
