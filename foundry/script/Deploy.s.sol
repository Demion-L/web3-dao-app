// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import "contracts/token/MyToken.sol";
import "contracts/governance_standard/TimeLock.sol";
import "contracts/governance_standard/GovernorContract.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey;
        address tokenOwner = vm.envAddress("TOKEN_OWNER");

        // Get the RPC URL and check if it's a testnet
        // If the RPC URL is not set, we assume it's a local development environment
        // and use the local private key.
        // If the RPC URL is set, we check if it's a testnet or mainnet.
        // If it's a testnet, we use the testnet private key.
        // If it's a mainnet, we revert to avoid accidental deployments.
        bool isTestnet = false;

        try vm.envString("SEPOLIA_RPC_URL") returns (string memory sepoliaUrl) {
            if (bytes(sepoliaUrl).length > 0) {
                isTestnet = true;
                console.log("Detected Sepolia configuration");
            }
        } catch {}

        // Get the appropriate private key
        if (isTestnet) {
            deployerPrivateKey = vm.envUint("TESTNET_PRIVATE_KEY");
            console.log("Using testnet private key");
        } else {
            deployerPrivateKey = vm.envUint("LOCAL_PRIVATE_KEY");
            console.log("Using local private key");
        }

        // // Only check for mainnet when actually broadcasting
        // if (block.chainid == 1) {
        //     revert("This script should not be run on mainnet");
        // }

        vm.startBroadcast(deployerPrivateKey);

        // deploy token
        MyToken token = new MyToken(tokenOwner);
        console.log("Token deployed to:", address(token));

        // deploy timelock
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        address admin = address(0);
        uint256 minDelay = 3600;

        TimeLock timeLock = new TimeLock(minDelay, proposers, executors, admin);
        console.log("TimeLock deployed to:", address(timeLock));

        // deploy governor
        uint256 votingDelay = 1;
        uint256 votingPeriod = 45818;
        uint256 quorumPercentage = 4;

        GovernorContract governor = new GovernorContract(
            token,
            timeLock,
            votingDelay,
            votingPeriod,
            quorumPercentage
        );
        console.log("Governor deployed to:", address(governor));

        vm.stopBroadcast();
    }
}
