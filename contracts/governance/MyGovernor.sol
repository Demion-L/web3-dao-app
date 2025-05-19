// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract MyGovernor is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorTimelockControl
{
    constructor(
        MyToken governanceToken_,
        IERC5792 timelock_
    )
        Governor("MyGovernor")
        GovernorSettings(
            1, // 1 block voting delay
            45818, // 1 week voting period (in blocks, assuming 15s blocks)
            1e18 // Proposal threshold: 1 token (assuming 18 decimals)
        )
        GovernorVotes(governanceToken_)
        GovernorTimelockControl(timelock_)
    {}

    // Minimum percentage of total supply needed to pass a proposal
    function quorum(
        uint256 blockNumber
    )
        public
        view
        override(IGovernor, GovernorQuorumFraction)
        returns (uint256)
    {
        return 4; // 4% of total supply
    }

    // The following functions are overrides required by Solidity

    // Function to get the voting delay
    // This function returns the voting delay in blocks
    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    // Function to get the voting period
    // This function returns the duration of the voting period in blocks
    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    // Function to get the proposal state
    // This function returns the state of a proposal based on its ID
    // It overrides the state function from Governor and GovernorTimelockControl
    // to ensure it uses the correct logic for determining proposal state
    function state(
        uint256 proposalId
    )
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    // Function to propose a new action
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override(Governor, IGovernor) returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    // Function to check if a proposal can be executed
    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        internal
        override(Governor, GovernorTimelockControl)
        returns (bytes memory)
    {
        return
            super._execute(proposalId, targets, values, calldatas, description);
    }

    // Function to cancel a proposal externally
    // This function allows anyone to cancel a proposal by providing the targets,
    // values, calldatas, and a salt
    // It overrides the cancel function from Governor and IGovernor
    // to ensure it uses the correct logic for canceling proposals
    // It returns the proposal ID of the canceled proposal
    // Note: This function can be called by anyone, not just the proposer
    // It is used to cancel a proposal before it is executed or finalized
    // It requires the proposal to be in a state that allows cancellation
    // It emits a ProposalCanceled event when the proposal is successfully canceled
    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 salt
    ) public override(Governor, IGovernor) returns (uint256) {
        return super.cancel(targets, values, calldatas, salt);
    }

    // Internal function to cancel a proposal
    // This function is used internally to cancel a proposal
    // It takes the same parameters as the cancel function
    // It is used to implement the logic for canceling a proposal
    // It is called by the cancel function to perform the actual cancellation
    // It requires the proposal to be in a state that allows cancellation
    // It returns the targets, values, calldatas, and salt used for cancellation
    // It overrides the _cancel function from Governor and GovernorTimelockControl
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 salt
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, salt);
    }

    // Function to get the executor address
    // This function returns the address of the executor for proposals
    // It overrides the _executor function from Governor and GovernorTimelockControl
    // It is used to determine who can execute proposals
    // It returns the address of the executor, which is typically the timelock contract
    // It is used to ensure that only the designated executor can execute proposals
    // It is called by the execute function to determine the executor address
    // It is required to implement the IGovernor interface
    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(Governor, GovernorTimelockControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Function to get the proposal count
    function proposalCount()
        public
        view
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.proposalCount();
    }

    // Getters functions
    // Function to get the proposal by ID
    function getProposal(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (Proposal memory) {
        return super.getProposal(proposalId);
    }

    // Function to get the proposal state by ID
    function proposalState(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (ProposalState) {
        return super.proposalState(proposalId);
    }

    // Function to get the proposal description by ID
    function proposalDescription(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (string memory) {
        return super.proposalDescription(proposalId);
    }

    // Function to get the proposal targets by ID
    function proposalTargets(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (address[] memory) {
        return super.proposalTargets(proposalId);
    }

    // Function to get the proposal values by ID
    function proposalValues(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256[] memory) {
        return super.proposalValues(proposalId);
    }

    // Function to get the proposal calldatas by ID
    function proposalCalldatas(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (bytes[] memory) {
        return super.proposalCalldatas(proposalId);
    }

    // Function to get the proposal start block by ID
    function proposalStartBlock(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalStartBlock(proposalId);
    }

    // Function to get the proposal end block by ID
    function proposalEndBlock(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalEndBlock(proposalId);
    }

    // Function to get the proposal snapshot block by ID
    function proposalSnapshot(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalSnapshot(proposalId);
    }

    // Function to get the proposal for a specific voter
    function proposalForVoter(
        uint256 proposalId,
        address voter
    ) public view override(Governor, IGovernor) returns (Proposal memory) {
        return super.proposalForVoter(proposalId, voter);
    }

    // Function to get the proposal votes by ID
    function proposalVotes(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalVotes(proposalId);
    }

    // Function to get the proposal execution time by ID
    function proposalExecutionTime(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalExecutionTime(proposalId);
    }

    // Function to get the proposal cancellation time by ID
    function proposalCancellationTime(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalCancellationTime(proposalId);
    }

    // Function to get the proposal proposer by ID
    function proposalProposer(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (address) {
        return super.proposalProposer(proposalId);
    }

    // Function to get the proposal executor by ID
    function proposalExecutor(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (address) {
        return super.proposalExecutor(proposalId);
    }

    // Function to get the proposal timelock by ID
    function proposalTimelock(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (address) {
        return super.proposalTimelock(proposalId);
    }

    // Function to get the proposal timelock delay by ID
    function proposalTimelockDelay(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockDelay(proposalId);
    }

    // Function to get the proposal timelock grace period by ID
    function proposalTimelockGracePeriod(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockGracePeriod(proposalId);
    }

    // Function to get the proposal timelock execution time by ID
    function proposalTimelockExecutionTime(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockExecutionTime(proposalId);
    }

    // Function to get the proposal timelock cancellation time by ID
    function proposalTimelockCancellationTime(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockCancellationTime(proposalId);
    }

    // Function to get the proposal timelock proposer by ID
    function proposalTimelockProposer(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (address) {
        return super.proposalTimelockProposer(proposalId);
    }

    // Function to get the proposal timelock executor by ID
    function proposalTimelockExecutor(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (address) {
        return super.proposalTimelockExecutor(proposalId);
    }

    // Function to get the proposal timelock state by ID
    function proposalTimelockState(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (ProposalState) {
        return super.proposalTimelockState(proposalId);
    }

    // Function to get the proposal timelock description by ID
    function proposalTimelockDescription(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (string memory) {
        return super.proposalTimelockDescription(proposalId);
    }

    // Function to get the proposal timelock targets by ID
    function proposalTimelockTargets(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (address[] memory) {
        return super.proposalTimelockTargets(proposalId);
    }

    // Function to get the proposal timelock values by ID
    function proposalTimelockValues(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256[] memory) {
        return super.proposalTimelockValues(proposalId);
    }

    // Function to get the proposal timelock calldatas by ID
    function proposalTimelockCalldatas(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (bytes[] memory) {
        return super.proposalTimelockCalldatas(proposalId);
    }

    // Function to get the proposal timelock start block by ID
    function proposalTimelockStartBlock(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockStartBlock(proposalId);
    }

    // Function to get the proposal timelock end block by ID
    function proposalTimelockEndBlock(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockEndBlock(proposalId);
    }

    // Function to get the proposal timelock snapshot block by ID
    function proposalTimelockSnapshot(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockSnapshot(proposalId);
    }

    // Function to get the proposal timelock for a specific voter
    function proposalTimelockForVoter(
        uint256 proposalId,
        address voter
    ) public view override(Governor, IGovernor) returns (Proposal memory) {
        return super.proposalTimelockForVoter(proposalId, voter);
    }

    // Function to get the proposal timelock votes by ID
    function proposalTimelockVotes(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockVotes(proposalId);
    }

    // Function to get the proposal timelock execution time by ID
    function proposalTimelockExecutionTime(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockExecutionTime(proposalId);
    }

    // Function to get the proposal timelock cancellation time by ID
    function proposalTimelockCancellationTime(
        uint256 proposalId
    ) public view override(Governor, IGovernor) returns (uint256) {
        return super.proposalTimelockCancellationTime(proposalId);
    }
}
