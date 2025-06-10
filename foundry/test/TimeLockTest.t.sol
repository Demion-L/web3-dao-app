// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Import Forge's testing library
import {Test, console2} from "forge-std/Test.sol";
// Import our TimeLock contract
import {TimeLock} from "contracts/governance_standard/TimeLock.sol";

/**
 * @title TimeLock Test Suite
 * @dev This is a basic test suite for the TimeLock contract
 */
contract TimeLockTest is Test {
    // Declare contract variables that we'll use in our tests
    TimeLock public timeLock;
    address public owner;
    address public proposer;
    address public executor;

    // Constants for our tests
    uint256 public constant MIN_DELAY = 3600; // 1 hour in seconds

    // setUp runs before each test
    function setUp() public {
        // Create test addresses using Forge's makeAddr helper
        owner = makeAddr("owner");
        proposer = makeAddr("proposer");
        executor = makeAddr("executor");

        // Create arrays for proposers and executors
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = proposer;
        executors[0] = executor;

        // Deploy the TimeLock contract
        // vm.startPrank(owner) makes all subsequent calls come from the owner address
        vm.startPrank(owner);
        timeLock = new TimeLock(MIN_DELAY, proposers, executors, owner);
        vm.stopPrank();
    }

    /**
     * @dev Tests the initial deployment of the TimeLock contract
     * @notice Verifies that:
     * - The minimum delay is set correctly
     * - The proposer has the PROPOSER_ROLE
     * - The executor has the EXECUTOR_ROLE
     * - The owner has the DEFAULT_ADMIN_ROLE
     */
    function test_Deployment() public view {
        // Check if the minimum delay is set correctly
        assertEq(
            timeLock.getMinDelay(),
            MIN_DELAY,
            "Min delay should be set correctly"
        );

        // Check if roles are assigned correctly
        assertTrue(
            timeLock.hasRole(timeLock.PROPOSER_ROLE(), proposer),
            "Proposer should have proposer role"
        );
        assertTrue(
            timeLock.hasRole(timeLock.EXECUTOR_ROLE(), executor),
            "Executor should have executor role"
        );
        assertTrue(
            timeLock.hasRole(timeLock.DEFAULT_ADMIN_ROLE(), owner),
            "Owner should have admin role"
        );
    }

    /**
     * @dev Tests that only the admin can update the minimum delay
     * @notice Verifies that:
     * - The admin can successfully update the delay
     * - The new delay value is correctly stored
     */
    function test_OnlyAdminCanUpdateDelay() public {
        vm.startPrank(owner);
        timeLock.updateDelay(7200);
        assertEq(
            timeLock.getMinDelay(),
            7200,
            "Delay should be updated by admin"
        );
        vm.stopPrank();
    }

    /**
     * @dev Tests that non-admin users cannot update the minimum delay
     * @notice Verifies that:
     * - An attacker without admin privileges cannot update the delay
     * - The transaction reverts when attempted by non-admin
     */
    function test_NonAdminCannotUpdateDelay() public {
        address attacker = makeAddr("attacker");

        vm.startPrank(attacker);
        vm.expectRevert(); // Expect the next call to fail
        timeLock.updateDelay(1800);
        vm.stopPrank();
    }

    /**
     * @dev Tests the admin's ability to grant proposer role to new addresses
     * @notice Verifies that:
     * - The admin can grant the PROPOSER_ROLE to a new address
     * - The new address successfully receives the role
     */
    function test_AdminCanGrantProposerRole() public {
        address newProposer = makeAddr("newProposer");

        vm.startPrank(owner);
        timeLock.grantRole(timeLock.PROPOSER_ROLE(), newProposer);
        assertTrue(timeLock.hasRole(timeLock.PROPOSER_ROLE(), newProposer));
        vm.stopPrank();
    }

    /**
     * @dev Tests the admin's ability to revoke executor role
     * @notice Verifies that:
     * - The admin can revoke the EXECUTOR_ROLE from an existing executor
     * - The executor no longer has the role after revocation
     */
    function test_AdminCanRevokeExecutorRole() public {
        vm.startPrank(owner);
        timeLock.revokeRole(timeLock.EXECUTOR_ROLE(), executor);
        assertFalse(timeLock.hasRole(timeLock.EXECUTOR_ROLE(), executor));
        vm.stopPrank();
    }
}
