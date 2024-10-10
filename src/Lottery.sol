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
    error NotEnoughEthToEnterLottery();

    uint256 private immutable i_entrancePrice;

    constructor(uint256 _entrancePrice) {
        i_entrancePrice = _entrancePrice;
    }

    receive() external payable {}

    fallback() external payable {}

    function enterLottery() public payable {}

    function pickWinner() public {}

    /** 
        View / Pure functions 
    */

    function getEntrancePrice() external view returns (uint256) {
        return i_entrancePrice;
    }
}
