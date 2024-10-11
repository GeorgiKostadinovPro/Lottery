// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 entrancePrice;
        uint256 lotteryDuration;
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }

    uint256 private constant SEPOLIA_ETH_CHAIN_ID = 11155111;
    uint256 private constant LOCAL_CHAIN_ID = 31337;

    uint96 private constant MOCK_VRF_BASE_FEE = 0.25 ether;
    uint96 private constant MOCK_VRF_GAS_PRICE_LINK = 1e9;
    int256 private constant MOCK_VRF_WEI_PER_UNIT_LINK = 4e15;

    NetworkConfig public anvilNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) private chainIdToNetworkConfig;

    constructor() {
        chainIdToNetworkConfig[SEPOLIA_ETH_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(
        uint256 _chainId
    ) public returns (NetworkConfig memory) {
        if (chainIdToNetworkConfig[_chainId].vrfCoordinator != address(0)) {
            return chainIdToNetworkConfig[_chainId];
        } else if (_chainId == LOCAL_CHAIN_ID) {
            return getAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /**
    * @dev The values for the NetworkConfig are not random.
    They are extracted from the Chainlink VRF Configurations.
    */
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entrancePrice: 0.01 ether,
                lotteryDuration: 30,
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0,
                callbackGasLimit: 2500000
            });
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (anvilNetworkConfig.vrfCoordinator != address(0)) {
            return anvilNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfMock = new VRFCoordinatorV2_5Mock(
            MOCK_VRF_BASE_FEE,
            MOCK_VRF_GAS_PRICE_LINK,
            MOCK_VRF_WEI_PER_UNIT_LINK
        );
        vm.stopBroadcast();

        anvilNetworkConfig = NetworkConfig({
            entrancePrice: 0.01 ether,
            lotteryDuration: 30,
            vrfCoordinator: address(vrfMock),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 2500000
        });

        return anvilNetworkConfig;
    }
}
