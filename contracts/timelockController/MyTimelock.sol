// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract MyTimelock is TimelockController {
    string public constant VERSION = "0.1.0";

    // Constructor to initialize the timelock controller with a delay and proposers/execs
    constructor(
        uint256 delay,
        address[] memory proposers,
        address[] memory executors
    ) TimelockController(delay, proposers, executors) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // Grant admin role to the deployer
    }
}
