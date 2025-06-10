// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {GovernorContract} from "../src/GovernorContract.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {MyToken} from "../src/token/MyToken.sol";
import {Box} from "../src/Box.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";

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
    uint256 public constant VOTING_DELAY = 1; // 1 block
    uint256 public constant VOTING_PERIOD = 45818; // ~1 week
    uint256 public constant QUORUM_PERCENTAGE = 4; // 4%
    uint256 public constant MIN_DELAY = 3600; // 1 hour

    // Proposal parameters
    uint256 public constant NEW_BOX_VALUE = 777;
    string public constant PROPOSAL_DESCRIPTION = "Update Box value to 777";

    function setUp() public {
        vm.startPrank(owner);

        // Deploy token
        token = new MyToken(owner);

        // Setup addresses for timelock
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(0); // Will be set to governor after deployment
        executors[0] = address(0); // Anyone can execute

        // Deploy timelock
        timelock = new TimeLock(
            MIN_DELAY,
            proposers,
            executors,
            address(0) // No admin
        );

        // Deploy governor
        governor = new GovernorContract(
            token,
            timelock,
            VOTING_DELAY,
            VOTING_PERIOD,
            QUORUM_PERCENTAGE
        );

        // Deploy the contract to be governed
        box = new Box();

        // Grant proposer role to governor
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));

        // Grant executor role to everyone (address(0))
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        // Transfer box ownership to timelock
        // Note: If Box had an owner, you'd transfer it here
        // For this simple Box, timelock will call setValue directly

        // Distribute tokens for voting
        token.mint(voter1, 100e18);
        token.mint(voter2, 200e18);
        token.mint(voter3, 300e18);

        vm.stopPrank();

        // Delegate votes to self for each voter
        vm.prank(voter1);
        token.delegate(voter1);

        vm.prank(voter2);
        token.delegate(voter2);

        vm.prank(voter3);
        token.delegate(voter3);

        // Move forward one block to activate delegated votes
        vm.roll(block.number + 1);
    }

    function testGovernorBasicSettings() public {
        assertEq(governor.name(), "GovernorContract");
        assertEq(governor.votingDelay(), VOTING_DELAY);
        assertEq(governor.votingPeriod(), VOTING_PERIOD);
        assertEq(governor.quorumNumerator(), QUORUM_PERCENTAGE);
    }

    function testTokenDistribution() public {
        assertEq(token.balanceOf(voter1), 100e18);
        assertEq(token.balanceOf(voter2), 200e18);
        assertEq(token.balanceOf(voter3), 300e18);

        // Check voting power
        assertEq(token.getVotes(voter1), 100e18);
        assertEq(token.getVotes(voter2), 200e18);
        assertEq(token.getVotes(voter3), 300e18);
    }

    function testCreateProposal() public {
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas
        ) = _getProposal();

        vm.prank(voter1);
        uint256 proposalId = governor.propose(
            targets,
            values,
            calldatas,
            PROPOSAL_DESCRIPTION
        );

        assertTrue(proposalId > 0);
        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Pending)
        );
    }

    function testCannotVoteBeforeVotingStarts() public {
        uint256 proposalId = _createProposal();

        // Try to vote before voting period starts
        vm.prank(voter1);
        vm.expectRevert("Governor: vote not currently active");
        governor.castVote(proposalId, 1); // 1 = For
    }

    function testVotingFlow() public {
        uint256 proposalId = _createProposal();

        // Move to voting period
        vm.roll(block.number + VOTING_DELAY + 1);

        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Active)
        );

        // Vote For
        vm.prank(voter1);
        governor.castVote(proposalId, 1); // For

        vm.prank(voter2);
        governor.castVote(proposalId, 1); // For

        // Vote Against
        vm.prank(voter3);
        governor.castVote(proposalId, 0); // Against

        // Check vote counts
        (
            uint256 againstVotes,
            uint256 forVotes,
            uint256 abstainVotes
        ) = governor.proposalVotes(proposalId);

        assertEq(forVotes, 300e18); // voter1 + voter2
        assertEq(againstVotes, 300e18); // voter3
        assertEq(abstainVotes, 0);
    }

    function testSuccessfulProposalExecution() public {
        uint256 proposalId = _createProposal();

        // Move to voting period and vote
        vm.roll(block.number + VOTING_DELAY + 1);

        // All voters vote FOR
        vm.prank(voter1);
        governor.castVote(proposalId, 1);

        vm.prank(voter2);
        governor.castVote(proposalId, 1);

        vm.prank(voter3);
        governor.castVote(proposalId, 1);

        // Move past voting period
        vm.roll(block.number + VOTING_PERIOD + 1);

        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Succeeded)
        );

        // Queue the proposal
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas
        ) = _getProposal();

        governor.queue(
            targets,
            values,
            calldatas,
            keccak256(bytes(PROPOSAL_DESCRIPTION))
        );

        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Queued)
        );

        // Wait for timelock delay
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // Execute the proposal
        uint256 initialValue = box.value();

        governor.execute(
            targets,
            values,
            calldatas,
            keccak256(bytes(PROPOSAL_DESCRIPTION))
        );

        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Executed)
        );
        assertEq(box.value(), NEW_BOX_VALUE);
        assertTrue(box.value() != initialValue);
    }

    function testFailedProposalDueToLackOfQuorum() public {
        uint256 proposalId = _createProposal();

        // Move to voting period
        vm.roll(block.number + VOTING_DELAY + 1);

        // Only voter1 votes (insufficient for quorum)
        vm.prank(voter1);
        governor.castVote(proposalId, 1);

        // Move past voting period
        vm.roll(block.number + VOTING_PERIOD + 1);

        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Defeated)
        );
    }

    function testCannotExecuteBeforeTimelock() public {
        uint256 proposalId = _createProposal();

        // Move to voting period and vote
        vm.roll(block.number + VOTING_DELAY + 1);

        // All voters vote FOR
        vm.prank(voter1);
        governor.castVote(proposalId, 1);

        vm.prank(voter2);
        governor.castVote(proposalId, 1);

        vm.prank(voter3);
        governor.castVote(proposalId, 1);

        // Move past voting period
        vm.roll(block.number + VOTING_PERIOD + 1);

        // Queue the proposal
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas
        ) = _getProposal();

        governor.queue(
            targets,
            values,
            calldatas,
            keccak256(bytes(PROPOSAL_DESCRIPTION))
        );

        // Try to execute immediately (should fail)
        vm.expectRevert("TimelockController: operation is not ready");
        governor.execute(
            targets,
            values,
            calldatas,
            keccak256(bytes(PROPOSAL_DESCRIPTION))
        );
    }

    function testProposalThreshold() public {
        // Create account with insufficient tokens
        address lowTokenUser = makeAddr("lowTokenUser");
        vm.prank(owner);
        token.mint(lowTokenUser, 1e18); // Only 1 token

        vm.prank(lowTokenUser);
        token.delegate(lowTokenUser);

        vm.roll(block.number + 1);

        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas
        ) = _getProposal();

        // Should fail due to insufficient tokens for proposal threshold
        vm.prank(lowTokenUser);
        vm.expectRevert("Governor: proposer votes below proposal threshold");
        governor.propose(targets, values, calldatas, PROPOSAL_DESCRIPTION);
    }

    // Helper functions
    function _createProposal() internal returns (uint256) {
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas
        ) = _getProposal();

        vm.prank(voter1);
        return
            governor.propose(targets, values, calldatas, PROPOSAL_DESCRIPTION);
    }

    function _getProposal()
        internal
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas
        )
    {
        targets = new address[](1);
        values = new uint256[](1);
        calldatas = new bytes[](1);

        targets[0] = address(box);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(
            Box.setValue.selector,
            NEW_BOX_VALUE
        );
    }
}
