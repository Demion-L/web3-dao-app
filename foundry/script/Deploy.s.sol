// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import "contracts/token/MyToken.sol";
import "contracts/governance_standard/TimeLock.sol";
import "contracts/governance_standard/GovernorContract.sol";
import "contracts/distribution/TokenDistributor.sol";

// This script deploys the MyToken, TimeLock, GovernorContract, and TokenDistributor contracts.
// It uses the deployer private key from the environment variables.
// It also checks if the RPC URL is set to a testnet or mainnet and uses the appropriate private key.
// It assumes the following environment variables are set:
// - TOKEN_OWNER: The address that will own the token.
// - TESTNET_PRIVATE_KEY: The private key for testnet deployments.
// - LOCAL_PRIVATE_KEY: The private key for local development deployments.
// - SEPOLIA_RPC_URL: The RPC URL for Sepolia testnet (optional).
// - MAINNET_RPC_URL: The RPC URL for mainnet (optional, but script will revert if used).
// Note: This script is designed to be run in a Foundry environment.
// It uses the forge-std library for scripting and console logging.
// It also uses OpenZeppelin's TimelockController for the TimeLock contract.

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey;
        address tokenOwner = vm.envAddress("TOKEN_OWNER");

        // Select the private key based on the chain ID you are deploying to.
        // This is a more reliable method than checking for environment variables.
        if (block.chainid == 1) {
            // Ethereum Mainnet
            revert("This script should not be run on mainnet");
        } else if (block.chainid == 11155111) {
            // Sepolia Testnet
            deployerPrivateKey = vm.envUint("TESTNET_PRIVATE_KEY");
            console.log(
                "Using Sepolia testnet private key for chain ID:",
                block.chainid
            );
        } else {
            // Default to local chains (Anvil, Hardhat, Ganache etc.)
            deployerPrivateKey = vm.envUint("LOCAL_PRIVATE_KEY");
            console.log("Using local private key for chain ID:", block.chainid);
        }

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

        // deploy distribution contract
        TokenDistributor distributor = new TokenDistributor(
            MyToken(token),
            tokenOwner
        );

        console.log("TokenDistributor deployed to:", address(distributor));

        vm.stopBroadcast();
    }
}
