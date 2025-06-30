// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TokenDistributor} from "contracts/distribution/TokenDistributor.sol";
import {MyToken} from "contracts/token/MyToken.sol";

/**
 * @title SetupDistributor
 * @notice Helper script for post-deployment setup of the TokenDistributor contract.
 * @dev This script provides functions to initialize vesting schedules and perform initial token distributions.
 *
 * Usage:
 *   - Set the DISTRIBUTOR_ADDRESS environment variable to the deployed TokenDistributor address.
 *   - Set the TESTNET_PRIVATE_KEY or LOCAL_PRIVATE_KEY as appropriate.
 *   - Run individual setup functions using forge script with the --sig flag.
 *
 * Example:
 *   forge script foundry/script/SetupDistributor.s.sol --sig "setupFoundingMembers()" --rpc-url $SEPOLIA_RPC_URL --broadcast
 */
contract SetupDistributor is Script {
    /**
     * @notice Sets up vesting schedules for founding members.
     * @dev Allocates tokens to founding members with a 6 month cliff and 18 month vesting period.
     * Reads DISTRIBUTOR_ADDRESS and TESTNET_PRIVATE_KEY from environment variables.
     */
    function setupFoundingMembers() external {
        address distributorAddress = vm.envAddress("DISTRIBUTOR_ADDRESS");
        TokenDistributor distributor = TokenDistributor(distributorAddress);

        uint256 deployerPrivateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Example founding member allocations
        address[] memory foundingMembers = new address[](3);
        uint256[] memory allocations = new uint256[](3);

        foundingMembers[0] = 0xF5089470fda725b9D86b09094d5f04054E853EbB; // You
        foundingMembers[1] = address(0x123); // Member 2
        foundingMembers[2] = address(0x456); // Member 3

        allocations[0] = 50_000 * 10 ** 18; // 50k tokens
        allocations[1] = 30_000 * 10 ** 18; // 30k tokens
        allocations[2] = 25_000 * 10 ** 18; // 25k tokens

        distributor.batchCreateVestingSchedules(
            foundingMembers,
            allocations,
            TokenDistributor.AllocationCategory.FOUNDING_MEMBERS,
            6, // 6 month cliff
            18 // 18 month total vesting
        );

        console.log("Founding member vesting schedules created");

        vm.stopBroadcast();
    }

    /**
     * @notice Sets up vesting schedules for core team members.
     * @dev Allocates tokens to core team with a 3 month cliff and 24 month vesting period.
     * Reads DISTRIBUTOR_ADDRESS and TESTNET_PRIVATE_KEY from environment variables.
     */
    function setupCoreTeam() external {
        address distributorAddress = vm.envAddress("DISTRIBUTOR_ADDRESS");
        TokenDistributor distributor = TokenDistributor(distributorAddress);

        uint256 deployerPrivateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Example core team allocations
        address[] memory coreMembers = new address[](2);
        uint256[] memory allocations = new uint256[](2);

        coreMembers[0] = address(0x789); // Lead developer
        coreMembers[1] = address(0xABC); // Core advisor

        allocations[0] = 30_000 * 10 ** 18; // 30k tokens
        allocations[1] = 15_000 * 10 ** 18; // 15k tokens

        distributor.batchCreateVestingSchedules(
            coreMembers,
            allocations,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            3, // 3 month cliff
            24 // 24 month total vesting
        );

        console.log("Core team vesting schedules created");

        vm.stopBroadcast();
    }

    /**
     * @notice Performs initial community token distribution.
     * @dev Distributes tokens to community members for public distribution.
     * Reads DISTRIBUTOR_ADDRESS and TESTNET_PRIVATE_KEY from environment variables.
     */
    function initialCommunityDistribution() external {
        address distributorAddress = vm.envAddress("DISTRIBUTOR_ADDRESS");
        TokenDistributor distributor = TokenDistributor(distributorAddress);

        uint256 deployerPrivateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Example community members for initial distribution
        address[] memory communityMembers = new address[](5);
        uint256[] memory amounts = new uint256[](5);

        for (uint256 i = 0; i < 5; i++) {
            communityMembers[i] = address(uint160(0x1000 + i)); // Placeholder addresses
            amounts[i] = 1_000 * 10 ** 18; // 1k tokens each
        }

        distributor.distributeTokens(
            communityMembers,
            amounts,
            TokenDistributor.AllocationCategory.PUBLIC_DISTRIBUTION
        );

        console.log("Initial community distribution completed");

        vm.stopBroadcast();
    }
}
