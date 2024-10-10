// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

/**
 * @title Lottery contract
 * @author Georgi Kostadinov / 0xAlipede
 * @notice A simple automated contract for Lottery
 * @dev Implements Chainlink VRFv2.5
 */
contract Lottery {
    /**
        Erros
    */
    error Lottery__NotEnoughEthToEnterLottery();

    /**
        State Variables
    */
    uint256 private immutable i_entrancePrice;

    address payable[] private s_participants;

    /**
        Events
    */
    event EnterLottery(address indexed participant);

    /**
        Functions
    */
    constructor(uint256 _entrancePrice) {
        i_entrancePrice = _entrancePrice;
    }

    receive() external payable {}

    fallback() external payable {}

    function enterLottery() public payable {
        if (msg.value < i_entrancePrice) {
            revert Lottery__NotEnoughEthToEnterLottery();
        }

        s_participants.push(payable(msg.sender));
        emit EnterLottery(msg.sender);
    }

    function pickWinner() public {}

    /** 
        View / Pure functions 
    */

    function getEntrancePrice() external view returns (uint256) {
        return i_entrancePrice;
    }
}
