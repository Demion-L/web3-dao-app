// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

import {GovernorContract} from "contracts/governance_standard/GovernorContract.sol";
import {TimeLock} from "contracts/governance_standard/TimeLock.sol";
import {MyToken} from "contracts/token/MyToken.sol";
import {Box} from "contracts/governance_standard/targets/Box.sol";

/**
 * @title GovernorContractTest
 * @dev Test suite for the GovernorContract implementation
 *
 * This test suite verifies the functionality of a governance system that includes:
 * - Token-based voting power
 * - Proposal creation and management
 * - Voting mechanism
 * - Timelock execution
 * - Quorum requirements
 *
 * The system uses a token (MyToken) for voting power, a timelock for execution delays,
 * and a simple Box contract as a target for governance actions.
 */
contract GovernorContractTest is Test {
    // Contract instances
    GovernorContract public governor;
    TimeLock public timelock;
    MyToken public token;
    Box public box;

    // Test addresses
    address public owner = makeAddr("owner");
    address public voter1 = makeAddr("voter1");
    address public voter2 = makeAddr("voter2");
    address public voter3 = makeAddr("voter3");

    // Governance parameters
    uint256 public constant VOTING_DELAY = 1; // 1 block delay before voting starts
    uint256 public constant VOTING_PERIOD = 45818; // ~1 week in blocks (15s blocks)
    uint256 public constant QUORUM_PERCENTAGE = 4; // 4% quorum required
    uint256 public constant MIN_DeLAY = 3600; // 1 hour timelock delay

    // Proposal parameters
    uint256 public constant NEW_BOX_VALUE = 777;
    string public constant PROPOSAL_DESCRIPTION = "Update box value to 777";

    /**
     * @dev Setup function that runs before each test
     * Initializes the governance system with:
     * - Token distribution to voters
     * - Timelock configuration
     * - Governor contract setup
     * - Box contract deployment
     */
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
        token.transfer(voter1, 15000e18); // 15000 tokens to voter1
        token.transfer(voter2, 20000e18); // 25000 tokens to voter2
        token.transfer(voter3, 25000e18); // 20000 tokens to voter3

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

    /**
     * @dev Helper function to get proposal parameters
     * @return targets Array of target addresses
     * @return values Array of ETH values to send
     * @return calldatas Array of function call data
     */
    function _getProposal()
        internal
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas
        )
    {
        // Set up the proposal to update the box value
        targets = new address[](1); // Array to hold contract addresses to call
        values = new uint256[](1); // Array to hold ETH amounts to send
        calldatas = new bytes[](1); // Array to hold function call data

        // Target is the box contract
        targets[0] = address(box);
        // No ETH to send
        values[0] = 0;
        // Encode the function call to setValue
        calldatas[0] = abi.encodeWithSignature(
            "setValue(uint256)",
            NEW_BOX_VALUE
        );

        return (targets, values, calldatas);
    }

    /**
     * @dev Helper function to create a new proposal
     * @return proposalId The ID of the created proposal
     */
    function _createProposal() internal returns (uint256 proposalId) {
        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas
        ) = _getProposal();
        vm.prank(voter1);
        return
            governor.propose(targets, values, calldatas, PROPOSAL_DESCRIPTION);
    }

    /**
     * @dev Test basic governor settings and configuration
     * Verifies:
     * - Governor name
     * - Voting delay and period
     * - Quorum settings
     * - Quorum calculation
     */
    function testGovernorBasicSettings() public view {
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

    /**
     * @dev Test token distribution and voting power
     * Verifies:
     * - Token balances for each voter
     * - Total token supply
     * - Voting power calculations
     * - Past votes tracking
     */
    function testTokensDistribution() public view {
        assertEq(
            token.balanceOf(voter1),
            15000e18,
            "Voter 1 should have 15000 tokens"
        );
        assertEq(
            token.balanceOf(voter2),
            20000e18,
            "Voter 2 should have 20000 tokens"
        );
        assertEq(
            token.balanceOf(voter3),
            25000e18,
            "Voter 3 should have 25000 tokens"
        );

        // Check total supply
        assertEq(
            token.totalSupply(),
            1000000e18, // 1 million tokens
            "Total supply should be 1 million tokens"
        );

        // Check voting power
        assertEq(
            token.getVotes(voter1),
            15000e18,
            "Voter 1 should have 15000 votes"
        );
        assertEq(
            token.getVotes(voter2),
            20000e18,
            "Voter 2 should have 20000 votes"
        );
        assertEq(
            token.getVotes(voter3),
            25000e18,
            "Voter 3 should have 25000 votes"
        );

        // Check past votes
        assertEq(
            token.getPastVotes(voter1, block.number - 1),
            15000e18,
            "Voter 1 should have 15000 past votes"
        );
        assertEq(
            token.getPastVotes(voter2, block.number - 1),
            20000e18,
            "Voter 2 should have 20000 past votes"
        );
        assertEq(
            token.getPastVotes(voter3, block.number - 1),
            25000e18,
            "Voter 3 should have 25000 past votes"
        );
    }

    /**
     * @dev Test proposal creation process
     * Verifies:
     * - Proposal creation with valid parameters
     * - Initial proposal state
     * - Proposal snapshot timing
     */
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

        // Check proposal creation
        assertTrue(proposalId > 0, "Proposal ID should be greater than 0");
        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Pending),
            "Proposal should be in Pending state"
        );
        assertEq(
            governor.proposalSnapshot(proposalId),
            block.number + VOTING_DELAY,
            "Proposal snapshot should be set correctly"
        );
    }

    /**
     * @dev Test voting restrictions before voting period
     * Verifies that voting is not allowed:
     * - Before voting delay has passed
     * - When proposal is in Pending state
     */
    function testCannotVoteBeforeVotingStarts() public {
        // 1. Create a new proposal
        uint256 proposalId = _createProposal();

        // 2. Try to vote immediately after proposal creation
        vm.prank(voter1);
        vm.expectRevert(
            abi.encodeWithSelector(
                IGovernor.GovernorUnexpectedProposalState.selector,
                proposalId,
                uint8(IGovernor.ProposalState.Pending), // current state is 0 (Pending)
                bytes32(uint256(2)) // the contract expects state 2
            )
        );
        governor.castVote(proposalId, 1); // Try to vote "Yes" (1 = Yes)
    }

    /**
     * @dev Test the complete voting flow
     * Verifies:
     * - Voting during active period
     * - Vote counting
     * - Support calculations (For/Against/Abstain)
     */
    function testVotingFlow() public {
        // 1. Create a new proposal
        uint256 proposalId = _createProposal();

        // 2. Move to voting period
        vm.roll(block.number + VOTING_DELAY + 1);

        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Active),
            "Proposal should be Active"
        );

        // 3. Voter 1 votes "Yes"
        vm.prank(voter1);
        governor.castVote(proposalId, 1); // 1 = Yes

        vm.prank(voter2);
        governor.castVote(proposalId, 1); // Voter 2 votes "Yes"

        // 4. Voter 3 votes "No"
        vm.prank(voter3);
        governor.castVote(proposalId, 0); // 0 = No

        // 5. Check voting results
        (
            uint256 againstVotes,
            uint256 forVotes,
            uint256 abstainVotes
        ) = governor.proposalVotes(proposalId);

        assertEq(forVotes, 35000e18, "Total Yes votes should be 35000");
        assertEq(againstVotes, 25000e18, "Total No votes should be 25000");
        assertEq(abstainVotes, 0, "Total Abstain votes should be 0");
    }

    /**
     * @dev Test successful proposal execution
     * Verifies the complete lifecycle:
     * - Proposal creation
     * - Voting
     * - Queuing
     * - Timelock delay
     * - Execution
     * - State changes
     */
    function testSuccessfulProposalExecution() public {
        // 1. Create a new proposal
        uint256 proposalId = _createProposal();

        // 2. Move to voting period
        vm.roll(block.number + VOTING_DELAY + 1);

        // 3. All votes FOR
        vm.prank(voter1);
        governor.castVote(proposalId, 1); // 1 = Yes
        vm.prank(voter2);
        governor.castVote(proposalId, 1); // Voter 2 votes "Yes"
        vm.prank(voter3);
        governor.castVote(proposalId, 1); // Voter 3 votes "Yes"

        // 4. Move to proposal end
        vm.roll(block.number + VOTING_PERIOD + VOTING_DELAY + 1);

        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Succeeded),
            "Proposal should be Succeeded"
        );

        // 5. Queue the proposal
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
            uint256(IGovernor.ProposalState.Queued),
            "Proposal should be Queued"
        );

        // 6. Wait for timelock delay
        vm.warp(block.timestamp + MIN_DeLAY + 1);

        // 7. Execute the proposal
        uint256 initialValue = box.value();

        governor.execute(
            targets,
            values,
            calldatas,
            keccak256(bytes(PROPOSAL_DESCRIPTION))
        );
        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Executed),
            "Proposal should be Executed"
        );
        assertEq(
            box.value(),
            NEW_BOX_VALUE,
            "Box value should be updated to 777"
        );
        assertTrue(
            box.value() != initialValue,
            "Box value should have changed from initial value"
        );
    }

    /**
     * @dev Test proposal failure due to insufficient quorum
     * Verifies that proposals fail when:
     * - Not enough votes are cast
     * - Quorum threshold is not met
     */
    function test_RevertWhen_ProposalFailsDueToLackOfQuorum() public {
        uint256 proposalId = _createProposal();

        // Move to voting period
        vm.roll(block.number + VOTING_DELAY + 1);

        // 1. Voter 1 votes "Yes"
        vm.prank(voter1);
        governor.castVote(proposalId, 1); // 1 = Yes

        // 2. Move to proposal end
        vm.roll(block.number + VOTING_PERIOD + VOTING_DELAY + 1);
        assertEq(
            uint256(governor.state(proposalId)),
            uint256(IGovernor.ProposalState.Defeated),
            "Proposal should be Defeated due to lack of quorum"
        );
    }

    /**
     * @dev Test execution restrictions before timelock delay
     * Verifies that proposals cannot be executed:
     * - Before timelock delay has passed
     * - When operation is not ready
     */
    function testCannotExecuteBeforeTimelock() public {
        uint256 proposalId = _createProposal();

        // Move to voting period and vote
        vm.roll(block.number + VOTING_DELAY + 1);

        // All voters vote "Yes"
        vm.prank(voter1);
        governor.castVote(proposalId, 1); // 1 = Yes
        vm.prank(voter2);
        governor.castVote(proposalId, 1); // Voter 2 votes "Yes"
        vm.prank(voter3);
        governor.castVote(proposalId, 1); // Voter 3 votes "Yes"

        // Move to past voting period
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

        // Try to execute immediately, should fail
        vm.expectRevert(
            abi.encodeWithSelector(
                TimelockController.TimelockUnexpectedOperationState.selector,
                0xdebda1f6a81eecee48d5fdf49c82e096ab0560ccbb2c896bf862e973c84a86c6,
                0x0000000000000000000000000000000000000000000000000000000000000004
            )
        );

        governor.execute(
            targets,
            values,
            calldatas,
            keccak256(bytes(PROPOSAL_DESCRIPTION))
        );
    }

    /**
     * @dev Test proposal threshold requirements
     * Verifies that users cannot create proposals when:
     * - They have insufficient voting power
     * - Their token balance is below the threshold
     */
    function testProposalThreshold() public {
        // Create account with insufficient tokens
        address lowTokenUser = makeAddr("lowTokenUser");
        vm.prank(owner);
        token.transfer(lowTokenUser, 1e18); // Only 1 token

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
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "GovernorInsufficientProposerVotes(address,uint256,uint256)"
                    )
                ),
                lowTokenUser,
                1e18, // actual votes
                4e18 // required votes
            )
        );
        governor.propose(targets, values, calldatas, PROPOSAL_DESCRIPTION);
    }
}
