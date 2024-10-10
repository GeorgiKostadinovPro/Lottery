// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Lottery contract
 * @author Georgi Kostadinov / 0xAlipede
 * @notice A simple automated contract for Lottery
 * @dev Implements Chainlink VRFv2.5
 */
contract Lottery is VRFConsumerBaseV2Plus {
    error Lottery__NotEnoughEthToEnterLottery();
    error Lottery__NotEnoughTimePassedToPickWinner();
    error Lottery__UnsuccessfulRewardTranfer();
    error Lottery__ChoosingWinner();

    enum LotteryState {
        OPEN,
        CHOOSING_WINNER
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entrancePrice;
    uint256 private immutable i_lotteryDuration;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint256 private s_lastTimeWinnerPicked;
    address payable[] private s_participants;

    LotteryState private s_lotteryState;

    event EnterLottery(address indexed participant);
    event ChosenWinner(address indexed winner);

    constructor(
        uint256 _entrancePrice,
        uint256 _lotteryDuration,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint256 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_entrancePrice = _entrancePrice;
        i_lotteryDuration = _lotteryDuration;
        s_lastTimeWinnerPicked = block.timestamp;

        i_keyHash = _keyHash;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;

        s_lotteryState = LotteryState.OPEN;
    }

    receive() external payable {}

    fallback() external payable {}

    function enterLottery() external payable {
        if (msg.value < i_entrancePrice) {
            revert Lottery__NotEnoughEthToEnterLottery();
        }

        if (s_lotteryState == LotteryState.CHOOSING_WINNER) {
            revert Lottery__ChoosingWinner();
        }

        s_participants.push(payable(msg.sender));
        emit EnterLottery(msg.sender);
    }

    function chooseWinner() external {
        if ((block.timestamp - s_lastTimeWinnerPicked) < i_lotteryDuration) {
            revert Lottery__NotEnoughTimePassedToPickWinner();
        }

        s_lotteryState = LotteryState.CHOOSING_WINNER;

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint[] calldata randomWords
    ) internal override {
        uint256 winnerIndex = randomWords[0] % s_participants.length;
        address payable winner = s_participants[winnerIndex];

        s_lotteryState = LotteryState.OPEN;
        s_lastTimeWinnerPicked = block.timestamp;
        s_participants = new address payable[](0);

        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Lottery__UnsuccessfulRewardTranfer();
        }

        emit ChosenWinner(winner);
    }

    function getEntrancePrice() external view returns (uint256) {
        return i_entrancePrice;
    }
}
