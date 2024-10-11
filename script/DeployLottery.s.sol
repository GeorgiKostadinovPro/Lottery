// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interactions.s.sol";

contract DeployLottery is Script {
    function deployLottery() public returns (Lottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            CreateSubscription createSubScript = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubScript
                .createSubscription(config.vrfCoordinator);
        }

        vm.startBroadcast();
        Lottery lottery = new Lottery(
            config.entrancePrice,
            config.lotteryDuration,
            config.vrfCoordinator,
            config.keyHash,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        return (lottery, helperConfig);
    }

    function run() external {}
}
