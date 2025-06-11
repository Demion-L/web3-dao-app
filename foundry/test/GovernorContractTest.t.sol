// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";

import {GovernorContract} from "contracts/governance_standard/GovernorContract.sol";
import {TimeLock} from "contracts/governance_standard/TimeLock.sol";
import {MyToken} from "contracts/token/MyToken.sol";
import {Box} from "contracts/governance_standard/targets/Box.sol";

contract GovernorContractTest is Test {
    GovernorContract public governor;
    TimeLock public timelock;
    MyToken public token;
    Box public box;

    // Test addresses
    address public owner = makeAddr("owner");
    address public voter1 = makeAddr("voter1");
    address public voter2 = makeAddr("voter2");
    address public voter3 = makeAddr("voter3");

    // Governor parameters
    uint256 public constant VOTING_DELAY = 1;
    uint256 public constant VOTING_PERIOD = 45818; // 1 week in blocks (assuming 15s blocks)
    uint256 public constant QUORUM_PERCENTAGE = 4; // 4% quorum
    uint256 public constant MIN_DeLAY = 3600; // 1 hour in seconds

    // Proposal parameters
    uint256 public constant NEW_BOX_VALUE = 777;
    string public constant PROPOSAL_DESCRIPTION = "Update box value to 777";

    function setUp() public {
        vm.startPrank(owner);

        // Deploy the token
        token = new MyToken(owner);

        // Setup addresses for timelock
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(0); // Will be set to governor after deployment
        executors[0] = address(0); // Anyone can execute

        // Deploy the timelock with owner as admin
        timelock = new TimeLock(
            MIN_DeLAY,
            proposers,
            executors,
            owner // Set owner as admin instead of address(0)
        );

        // Deploy the governor
        governor = new GovernorContract(
            token,
            timelock,
            VOTING_DELAY,
            VOTING_PERIOD,
            QUORUM_PERCENTAGE
        );

        // Deploy the box contract
        box = new Box();

        // Grant proposer role to the governor (now owner has permission to do this)
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));

        // Grant executor role to the governor
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        // Transfer box ownership to timelock
        // Notice: If Box had an owner, you would transfer ownership here
        // For this simple Box, timelock will call setValue directly

        // Transfer tokens to voters (instead of minting)
        token.transfer(voter1, 100e18);
        token.transfer(voter2, 200e18);
        token.transfer(voter3, 300e18);

        vm.stopPrank();

        vm.prank(voter1);
        token.delegate(voter1); // Voter 1 delegates to themselves

        vm.prank(voter2);
        token.delegate(voter2); // Voter 2 delegates to themselves

        vm.prank(voter3);
        token.delegate(voter3); // Voter 3 delegates to themselves

        // Move forward one block to activate the delegation
        vm.roll(block.number + 1);
    }

    function testGovernorBasicSettings() public {
        assertEq(governor.name(), "GovernorContract");
        assertEq(governor.votingDelay(), VOTING_DELAY);
        assertEq(governor.votingPeriod(), VOTING_PERIOD);

        // Test quorum numerator - GovernorVotesQuorumFraction uses numerator/denominator
        assertEq(governor.quorumNumerator(), QUORUM_PERCENTAGE);
        assertEq(governor.quorumDenominator(), 100);

        // Test actual quorum calculation at current block
        uint256 totalSupply = token.totalSupply();
        uint256 expectedQuorum = (totalSupply * QUORUM_PERCENTAGE) / 100;
        assertEq(governor.quorum(block.number - 1), expectedQuorum);
    }
}
