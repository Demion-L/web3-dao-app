# Smart Contract Documentation

## Overview

This documentation covers the smart contracts used in the DAO governance system. The system consists of three main contracts:

- MyToken (ERC20Votes)
- TimeLock
- GovernorContract

## Contract Details

### MyToken (ERC20Votes)

**Location**: `contracts/token/MyToken.sol`

A governance token that implements ERC20Votes for voting power delegation.

#### State Variables

- `s_maxSupply`: Maximum token supply (1,000,000 tokens with 18 decimals)

#### Constructor

```solidity
constructor() ERC20("MyToken", "MT") EIP712("MyToken", "1")
```

- Initializes the token with name "MyToken" and symbol "MT"
- Mints the maximum supply to the deployer

#### Functions

- `_update(address from, address to, uint256 value)`: Internal function required by ERC20Votes for vote delegation

### TimeLock

**Location**: `contracts/governance_standard/TimeLock.sol`

A timelock controller that enforces a minimum delay for executing proposals.

#### Constructor

```solidity
constructor(
    uint256 minDelay,
    address[] memory proposers,
    address[] memory executors,
    address admin
)
```

- `minDelay`: Minimum time delay before executing a proposal
- `proposers`: Array of addresses that can propose
- `executors`: Array of addresses that can execute
- `admin`: Optional admin address (can be zero address)

### GovernorContract

**Location**: `contracts/governance_standard/GovernorContract.sol`

The main governance contract that handles proposal creation, voting, and execution.

#### Inherited Contracts

- Governor
- GovernorSettings
- GovernorCountingSimple
- GovernorStorage
- GovernorVotes
- GovernorVotesQuorumFraction
- GovernorTimelockControl

#### Constructor

```solidity
constructor(
    MyToken myToken,
    TimelockController _timelock,
    uint256 _votingDelay,
    uint256 _votingPeriod,
    uint256 _quorumPercentage
)
```

- `myToken`: The governance token contract
- `_timelock`: The timelock controller contract
- `_votingDelay`: Delay before voting starts (in blocks)
- `_votingPeriod`: Duration of voting period (in blocks)
- `_quorumPercentage`: Required percentage of total supply for quorum

#### Key Functions

##### State Management

```solidity
function state(uint256 proposalId) public view returns (ProposalState)
```

- Returns the current state of a proposal

##### Proposal Management

```solidity
function proposalNeedsQueuing(uint256 proposalId) public view returns (bool)
```

- Checks if a proposal needs to be queued in the timelock

```solidity
function proposalThreshold() public view returns (uint256)
```

- Returns the minimum number of votes required to create a proposal

##### Internal Functions

```solidity
function _propose(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    string memory description,
    address proposer
) internal returns (uint256)
```

- Internal function for creating new proposals

```solidity
function _queueOperations(
    uint256 proposalId,
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
) internal returns (uint48)
```

- Queues proposal operations in the timelock

```solidity
function _executeOperations(
    uint256 proposalId,
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
) internal
```

- Executes proposal operations after timelock delay

## Deployment

The contracts are deployed using the `Deploy.s.sol` script with the following parameters:

### MyToken

- Maximum supply: 1,000,000 tokens (with 18 decimals)

### TimeLock

- Minimum delay: 3600 seconds (1 hour)
- Initial proposers: Empty array
- Initial executors: Empty array
- Admin: Zero address

### GovernorContract

- Voting delay: 1 block
- Voting period: 45818 blocks (approximately 1 week)
- Quorum percentage: 4%

## Usage Flow

1. Users must hold MyToken to participate in governance
2. Token holders can delegate their voting power
3. Proposals can be created by addresses with sufficient voting power
4. Proposals go through the following states:
   - Pending
   - Active
   - Canceled
   - Defeated
   - Succeeded
   - Queued
   - Expired
   - Executed
5. Successful proposals must wait for the timelock delay before execution

## Security Considerations

- The TimeLock contract provides a safety mechanism for executing proposals
- The quorum requirement ensures sufficient participation
- The voting period and delay parameters can be adjusted based on network conditions
- The system uses OpenZeppelin's battle-tested contracts for core functionality
