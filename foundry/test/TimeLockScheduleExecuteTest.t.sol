// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {TimeLock} from "contracts/governance_standard/TimeLock.sol";
import {Box} from "contracts/governance_standard/targets/Box.sol";

contract TimeLockScheduleExecuteTest is Test {
    TimeLock public timeLock;
    Box public box;

    address public admin;
    address public proposer;
    address public executor;

    uint256 public constant MIN_DELAY = 3600;

    function setUp() public {
        admin = makeAddr("admin");
        proposer = makeAddr("proposer");
        executor = makeAddr("executor");

        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);

        proposers[0] = proposer;
        executors[0] = executor;

        vm.startPrank(admin);
        timeLock = new TimeLock(MIN_DELAY, proposers, executors, admin);
        box = new Box();
        vm.stopPrank();
    }

    function test_ScheduleAndExecuteSetValue() public {
        uint newValue = 42;
        bytes memory data = abi.encodeWithSelector(
            box.setValue.selector,
            newValue
        );

        address target = address(box);
        uint256 value = 0;
        bytes32 predecessor = bytes32(0);
        bytes32 salt = keccak256("some-salt");

        // Schedule
        vm.prank(proposer);
        timeLock.schedule(target, value, data, predecessor, salt, MIN_DELAY);

        // Warp forward
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // Execute
        vm.prank(executor);
        timeLock.execute(target, value, data, predecessor, salt);

        // Assert
        assertEq(box.value(), newValue, "Value should be set correctly");
    }
}
