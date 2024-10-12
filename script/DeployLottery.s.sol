// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployLottery is Script {
    function deployLottery() public returns (Lottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            CreateSubscription createSubScript = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubScript
                .createSubscription(config.vrfCoordinator);

            FundSubscription fundSubScript = new FundSubscription();
            fundSubScript.fundSubscription(
                config.vrfCoordinator,
                config.subscriptionId,
                config.link
            );
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

        AddConsumer addConsumerScript = new AddConsumer();
        addConsumerScript.addConsumer(
            address(lottery),
            config.vrfCoordinator,
            config.subscriptionId
        );

        return (lottery, helperConfig);
    }

    function run() external {
        deployLottery();
    }
}
