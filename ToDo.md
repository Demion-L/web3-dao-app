# Project ToDo List

## Front-end integration

### Contract Integration Setup

- [x] Set up web3 library (ethers.js or web3.js)
- [x] Create contracts directory in frontend
- [x] Copy and organize contract ABIs
- [ ] Create contract interaction utilities
- [ ] Implement contract instance creation

### Core Features Implementation

- [x] Create proposal creation form
- [ ] Implement proposal listing
- [ ] Add proposal details view
- [ ] Create voting interface
- [ ] Implement proposal status tracking
- [ ] Add transaction status monitoring

### State Management

- [x] Set up state management solution
- [x] Track connected wallet state
- [x] Manage user's token balance
- [ ] Track voting power
- [ ] Monitor proposal states
- [ ] Handle transaction statuses

### Event Handling

- [ ] Implement contract event listeners
- [ ] Add real-time proposal updates
- [ ] Handle voting event updates
- [ ] Monitor execution events
- [ ] Implement event error handling

### Error Handling & UX

- [ ] Add transaction failure handling
- [ ] Implement gas estimation
- [ ] Handle user rejections
- [ ] Add network error handling
- [ ] Create loading states
- [ ] Implement success/error notifications
- [ ] Add mobile responsiveness
- [ ] Create user instructions and tooltips
- [ ] Add animated transitions (e.g., with Framer Motion)
- [ ] Animate wallet connection/disconnection
- [ ] Display proposals in glass cards with neon highlights for status
- [ ] Add a modal for creating proposals with neon-glow form fields

### DAO Lifecycle and Tokenomics Integration

- [ ] **Vesting and Distribution:**
  - [ ] Integrate `TokenDistributor` contract ABI.
  - [ ] Create UI for admins to create and manage vesting schedules.
  - [ ] Create UI for beneficiaries to view their vesting schedule (`getVestingInfo`).
  - [ ] Implement "Claim Tokens" button for users with vested tokens (`claimVestedTokens`).
- [ ] **Governance Rewards:**
  - [ ] Connect `rewardVoting()` in `TokenDistributor` to the frontend voting action.
  - [ ] Connect `rewardProposal()` in `TokenDistributor` to the proposal creation/success logic.
  - [ ] Display user-specific governance rewards on their profile/dashboard.

### Testing & Deployment

- [ ] Write unit tests for contract interactions
- [ ] Create integration tests
- [ ] Implement end-to-end tests
- [ ] Set up different network configurations
- [ ] Configure environment variables
- [ ] Optimize gas usage

## DeFi Features to Implement

- [ ] Liquidity Pools: Allow users to provide liquidity and earn fees
- [ ] Yield Farming: Add more complex reward mechanisms
- [ ] Token Swaps: Add a DEX (Decentralized Exchange) to swap tokens
- [ ] Lending/Borrowing: Allow users to lend their tokens and earn interest
- [ ] NFT Integration: Add NFT staking or governance

## Current Features

- [x] Basic DAO Governance
- [x] Token Staking
- [x] Reward Distribution

---

# DAO Launch Plan: From Deployment to Live Operations

This plan outlines the end-to-end process for launching the DAO, based on the newly defined smart contract architecture.

## Phase 0: Setup and Deployment (Owner's Manual)

- [ ] **1. Deploy Contracts:**
  - [ ] Deploy `MTK.sol` (Token Contract).
  - [ ] Deploy `TokenDistributor.sol` (using MTK address).
  - [ ] Deploy `StakingRewards.sol` (using MTK address).
  - [ ] Deploy `Governor.sol` (Core Governance Contract).
- [ ] **2. Fund Contracts:**
  - [ ] Transfer the total allocated token supply for vesting and rewards to the `TokenDistributor` contract.
  - [ ] Transfer the initial token supply for staking rewards to the `StakingRewards` contract.
- [ ] **3. Set Up Initial Allocations:**
  - [ ] Use `TokenDistributor.createVestingSchedule()` to set up schedules for founders, team, and partners.
  - [ ] Use `TokenDistributor.batchCreateVestingSchedules()` for efficiency if applicable.
- [ ] **4. Decentralize Ownership:**
  - [ ] **CRITICAL:** Transfer the `owner` role of all contracts (`TokenDistributor`, `StakingRewards`, `MTK` minter role) to the `Governor` contract address.

## Phase 1: Live DAO Operations (User & Governance Flow)

- [ ] **1. User Staking:**
  - [ ] Frontend allows users to call `stake()` on `StakingRewards.sol`.
  - [ ] UI correctly reflects staked balance and potential rewards (`earned()`).
- [ ] **2. Proposal Lifecycle:**
  - [ ] Users with sufficient staked tokens can submit proposals via the UI (`propose()` on `Governor`).
  - [ ] Active proposals are displayed for voting.
- [ ] **3. Voting and Rewards:**
  - [ ] Staked users can vote on proposals.
  - [ ] After a vote is cast, trigger `rewardVoting()` on `TokenDistributor` to reward the voter.
  - [ ] UI provides feedback that the vote was successful and a reward was earned.
- [ ] **4. Proposal Execution:**
  - [ ] After a vote passes, the UI allows anyone to call `execute()` on the `Governor`.
  - [ ] The `Governor` executes the proposal (e.g., a token transfer from the `TokenDistributor`).
  - [ ] On successful execution, trigger `rewardProposal()` on `TokenDistributor` to reward the proposer.
