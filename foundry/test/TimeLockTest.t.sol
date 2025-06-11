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
     * @dev Tests updating the delay through proper governance process
     * @notice Verifies that:
     * - A proposal can be scheduled to update the delay
     * - After the delay period, the proposal can be executed
     * - The delay is updated correctly
     */
    function test_UpdateDelayThroughGovernance() public {
        uint256 newDelay = 7200; // 2 hours

        // Prepare the call data for updateDelay
        bytes memory data = abi.encodeWithSignature(
            "updateDelay(uint256)",
            newDelay
        );

        // Create a unique salt for this operation
        bytes32 salt = keccak256("update_delay_proposal");

        // Calculate the operation ID
        bytes32 id = timeLock.hashOperation(
            address(timeLock), // target is the timelock itself
            0, // value
            data, // call data
            bytes32(0), // predecessor
            salt // salt
        );

        // Step 1: Schedule the operation (proposer role required)
        vm.startPrank(proposer);
        timeLock.schedule(
            address(timeLock), // target
            0, // value
            data, // data
            bytes32(0), // predecessor
            salt, // salt
            MIN_DELAY // delay
        );
        vm.stopPrank();

        // Verify the operation is scheduled
        assertTrue(
            timeLock.isOperationPending(id),
            "Operation should be pending"
        );

        // Step 2: Fast forward time to after the delay
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // Verify the operation is now ready
        assertTrue(timeLock.isOperationReady(id), "Operation should be ready");

        // Step 3: Execute the operation (executor role required)
        vm.startPrank(executor);
        timeLock.execute(
            address(timeLock), // target
            0, // value
            data, // data
            bytes32(0), // predecessor
            salt // salt
        );
        vm.stopPrank();

        // Verify the delay was updated
        assertEq(
            timeLock.getMinDelay(),
            newDelay,
            "Delay should be updated through governance"
        );

        // Verify the operation is now done
        assertTrue(timeLock.isOperationDone(id), "Operation should be done");
    }

    /**
     * @dev Tests that non-proposers cannot schedule operations
     * @notice Verifies that:
     * - An attacker without proposer privileges cannot schedule operations
     * - The transaction reverts when attempted by non-proposer
     */
    function test_NonProposerCannotSchedule() public {
        address attacker = makeAddr("attacker");

        bytes memory data = abi.encodeWithSignature(
            "updateDelay(uint256)",
            1800
        );
        bytes32 salt = keccak256("malicious_proposal");

        vm.startPrank(attacker);
        vm.expectRevert(); // Expect the next call to fail
        timeLock.schedule(
            address(timeLock),
            0,
            data,
            bytes32(0),
            salt,
            MIN_DELAY
        );
        vm.stopPrank();
    }

    /**
     * @dev Tests that non-executors cannot execute ready operations
     * @notice Verifies that:
     * - Even if an operation is ready, non-executors cannot execute it
     * - The transaction reverts when attempted by non-executor
     */
    function test_NonExecutorCannotExecute() public {
        address attacker = makeAddr("attacker");

        // First, let's schedule a legitimate operation
        bytes memory data = abi.encodeWithSignature(
            "updateDelay(uint256)",
            7200
        );
        bytes32 salt = keccak256("legitimate_proposal");

        vm.startPrank(proposer);
        timeLock.schedule(
            address(timeLock),
            0,
            data,
            bytes32(0),
            salt,
            MIN_DELAY
        );
        vm.stopPrank();

        // Fast forward time
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // Now try to execute as attacker
        vm.startPrank(attacker);
        vm.expectRevert(); // Expect the next call to fail
        timeLock.execute(address(timeLock), 0, data, bytes32(0), salt);
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
