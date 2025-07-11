// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

/**
 * @title TokenDistributor
 * @dev Manages token distribution with vesting schedules for different allocation categories
 */
contract TokenDistributor is Ownable, ReentrancyGuard {
    /// @notice The ERC20 token being distributed
    IERC20 public immutable token;

    /**
     * @notice Allocation categories of token recipients
     * @dev These categories represent different groups of token holders
     */
    enum AllocationCategory {
        TREASURY,
        FOUNDING_MEMBERS,
        CORE_TEAM,
        COMMUNITY_INCENTIVES,
        PUBLIC_DISTRIBUTION,
        LIQUIDITY_PARTNERSHIPS
    }

    /**
     * @notice Vesting schedule for a beneficiary
     * @dev Defines vesting parameters for each beneficiary
     * @param totalAllocation Total tokens assigned
     * @param cliffDuration Duration (in seconds) before tokens start unlocking
     * @param vestingDuration Total duration (in seconds) for full vesting
     * @param startTime Timestamp when vesting starts
     * @param claimed Amount of tokens already claimed
     * @param revoked Whether the schedule is canceled
     */
    struct VestingSchedule {
        uint256 totalAllocation;
        uint256 cliffDuration;
        uint256 vestingDuration;
        uint256 startTime;
        uint256 claimed;
        bool revoked;
    }

    /// @notice Maximum tokens each category can receive
    mapping(AllocationCategory => uint256) public categoryLimits;
    /// @notice Tokens already allocated to each category
    mapping(AllocationCategory => uint256) public categoryAllocated;
    /// @notice Vesting schedules for each beneficiary
    mapping(address => VestingSchedule) public vestingSchedules;

    /// @notice Governance rewards earned by each address
    mapping(address => uint256) public governanceRewards;
    /// @notice Last time a user was rewarded for voting
    mapping(address => uint256) public lastVoteTime;
    /// @notice Proposal rewards earned by each address
    mapping(address => uint256) public proposalRewards;

    /**
     * @notice Emitted when a vesting schedule is created
     * @param beneficiary Address of the beneficiary
     * @param amount Amount allocated
     * @param startTime Vesting start time
     */
    event VestingScheduleCreated(
        address indexed beneficiary,
        uint256 amount,
        uint256 startTime
    );

    /**
     * @notice Emitted when tokens are claimed
     * @param beneficiary Address of the beneficiary
     * @param amount Amount claimed
     */
    event TokensClaimed(address indexed beneficiary, uint256 amount);

    /**
     * @notice Emitted when a governance reward is granted
     * @param user Address of the user
     * @param amount Amount rewarded
     * @param reason Reason for the reward
     */
    event GovernanceRewardGranted(
        address indexed user,
        uint256 amount,
        string reason
    );

    /**
     * @notice Emitted when a vesting schedule is revoked
     * @param beneficiary Address of the beneficiary
     */
    event VestingRevoked(address indexed beneficiary);

    /**
     * @notice Initializes the contract and sets category limits
     * @param _token The ERC20 token to distribute
     * @param initialOwner The initial owner of the contract
     */
    constructor(IERC20 _token, address initialOwner) Ownable(initialOwner) {
        token = _token;
        // Set category limits (based on 1M token supply)
        categoryLimits[AllocationCategory.TREASURY] = 400_000 * 10 ** 18;
        categoryLimits[AllocationCategory.FOUNDING_MEMBERS] =
            250_000 *
            10 ** 18;
        categoryLimits[AllocationCategory.CORE_TEAM] = 150_000 * 10 ** 18;
        categoryLimits[AllocationCategory.COMMUNITY_INCENTIVES] =
            100_000 *
            10 ** 18;
        categoryLimits[AllocationCategory.PUBLIC_DISTRIBUTION] =
            50_000 *
            10 ** 18;
        categoryLimits[AllocationCategory.LIQUIDITY_PARTNERSHIPS] =
            50_000 *
            10 ** 18;
    }

    // @notice Modifier to delegate voting power on token transfer
    // This modifier delegates voting power to the recipient on token transfers
    // It skips delegation for treasury and contract addresses to avoid unnecessary delegation
    modifier delegateOnTransfer(address recipient, uint256 amount) {
        _;
        // Skip delegation for treasury and contract addresses
        if (recipient != owner() && recipient != address(this) && amount > 0) {
            ERC20Votes(address(token)).delegate(recipient);
        }
    }

    /**
     * @notice Create vesting schedule for a beneficiary
     * @dev Only callable by the owner
     * @param beneficiary Address of the beneficiary
     * @param allocation Total tokens allocated
     * @param category Allocation category
     * @param cliffMonths Cliff period in months
     * @param vestingMonths Total vesting period in months
     */
    function createVestingSchedule(
        address beneficiary,
        uint256 allocation,
        AllocationCategory category,
        uint256 cliffMonths,
        uint256 vestingMonths
    ) public onlyOwner delegateOnTransfer(beneficiary, allocation) {
        require(beneficiary != address(0), "Invalid beneficiary address");
        require(allocation > 0, "Allocation must be greater than zero");
        require(
            vestingSchedules[beneficiary].totalAllocation == 0,
            "Vesting schedule already exists for this address"
        );
        // Check category limits
        require(
            categoryAllocated[category] + allocation <=
                categoryLimits[category],
            "Category allocation limit exceeded"
        );
        uint256 cliffDuration = cliffMonths * 30 days; // Convert months to seconds
        uint256 vestingDuration = vestingMonths * 30 days; // Convert months to seconds
        vestingSchedules[beneficiary] = VestingSchedule({
            totalAllocation: allocation,
            cliffDuration: cliffDuration,
            vestingDuration: vestingDuration,
            startTime: block.timestamp,
            claimed: 0,
            revoked: false
        });
        categoryAllocated[category] += allocation;
        emit VestingScheduleCreated(beneficiary, allocation, block.timestamp);
    }

    /**
     * @notice Batch create vesting schedules for multiple beneficiaries
     * @dev Only callable by the owner
     * @param beneficiaries Array of beneficiary addresses
     * @param allocations Array of token allocations
     * @param category Allocation category
     * @param cliffMonths Cliff period in months
     * @param vestingMonths Total vesting period in months
     */
    function batchCreateVestingSchedules(
        address[] calldata beneficiaries,
        uint256[] calldata allocations,
        AllocationCategory category,
        uint256 cliffMonths,
        uint256 vestingMonths
    ) external onlyOwner {
        require(
            beneficiaries.length == allocations.length,
            "Beneficiaries and allocations length mismatch"
        );
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            createVestingSchedule(
                beneficiaries[i],
                allocations[i],
                category,
                cliffMonths,
                vestingMonths
            );
        }
    }

    /**
     * @notice Calculate vested amount for a beneficiary
     * @param beneficiary Address to check
     * @return vestedAmount Amount of tokens vested
     */
    function calculateVestedAmount(
        address beneficiary
    ) public view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[beneficiary];
        // Check if vesting schedule exists
        if (schedule.revoked || schedule.totalAllocation == 0) {
            return 0;
        }
        uint256 currentTime = block.timestamp;
        // Before cliff
        if (currentTime < schedule.startTime + schedule.cliffDuration) {
            return 0;
        }
        // After full vesting
        if (currentTime >= schedule.startTime + schedule.vestingDuration) {
            return schedule.totalAllocation;
        }
        // During vesting period
        uint256 vestedTime = currentTime -
            schedule.startTime -
            schedule.cliffDuration;
        uint256 vestingTime = schedule.vestingDuration - schedule.cliffDuration;
        if (vestingTime == 0) {
            return 0; // Avoid division by zero
        }
        return (schedule.totalAllocation * vestedTime) / vestingTime;
    }

    /**
     * @notice Get claimable amount for a beneficiary
     * @param beneficiary Address to check
     * @return claimableAmount Amount that can be claimed
     */
    function getClaimableAmount(
        address beneficiary
    ) public view returns (uint256) {
        require(beneficiary != address(0), "Invalid beneficiary address");
        // Check for revoked first to ensure the correct error message.
        require(
            !vestingSchedules[beneficiary].revoked,
            "Vesting schedule revoked"
        );
        require(
            vestingSchedules[beneficiary].totalAllocation > 0,
            "No vesting schedule for this address"
        );
        uint256 vestedAmount = calculateVestedAmount(beneficiary);
        uint256 claimed = vestingSchedules[beneficiary].claimed;
        return vestedAmount > claimed ? vestedAmount - claimed : 0;
    }

    /**
     * @notice Claim vested tokens for the caller
     * @dev Only callable by the beneficiary
     */
    function claimVestedTokens() external nonReentrant {
        uint256 claimableAmount = getClaimableAmount(msg.sender);
        require(claimableAmount > 0, "No tokens to claim");
        vestingSchedules[msg.sender].claimed += claimableAmount;
        require(token.transfer(msg.sender, claimableAmount), "Transfer failed");
        emit TokensClaimed(msg.sender, claimableAmount);
    }

    /**
     * @notice Grant governance participation rewards to a user
     * @dev Only callable by the owner
     * @param user Address of the user
     * @param amount Reward amount
     * @param reason Reason for the reward
     */
    function grantGovernanceReward(
        address user,
        uint256 amount,
        string memory reason
    ) public onlyOwner {
        require(
            categoryAllocated[AllocationCategory.COMMUNITY_INCENTIVES] +
                amount <=
                categoryLimits[AllocationCategory.COMMUNITY_INCENTIVES],
            "Exceeds community incentives limit"
        );
        governanceRewards[user] += amount;
        categoryAllocated[AllocationCategory.COMMUNITY_INCENTIVES] += amount;
        require(token.transfer(user, amount), "Transfer failed");
        emit GovernanceRewardGranted(user, amount, reason);
    }

    /**
     * @notice Batch grant governance rewards to multiple users
     * @dev Only callable by the owner
     * @param users Array of user addresses
     * @param amounts Array of reward amounts
     * @param reason Reason for the reward
     */
    function batchGrantGovernanceRewards(
        address[] calldata users,
        uint256[] calldata amounts,
        string memory reason
    ) external onlyOwner {
        require(users.length == amounts.length, "Array length mismatch");
        for (uint256 i = 0; i < users.length; i++) {
            grantGovernanceReward(users[i], amounts[i], reason);
        }
    }

    /**
     * @notice Reward voting participation for a user
     * @dev Only callable by the owner (should be called by governance contract)
     * @param voter Address of the voter
     */
    function rewardVoting(address voter) external onlyOwner {
        uint256 reward = 10 * 10 ** 18; // 10 MTK per vote
        // Limit to one reward per day per user
        require(
            lastVoteTime[voter] == 0 ||
                block.timestamp >= lastVoteTime[voter] + 1 days,
            "Already rewarded today"
        );
        lastVoteTime[voter] = block.timestamp;
        grantGovernanceReward(voter, reward, "Voting participation");
    }

    /**
     * @notice Reward successful proposal creation
     * @dev Only callable by the owner (should be called by governance contract)
     * @param proposer Address of the proposer
     */
    function rewardProposal(address proposer) external onlyOwner {
        uint256 reward = 100 * 10 ** 18; // 100 MTK per successful proposal
        proposalRewards[proposer] += reward;
        grantGovernanceReward(proposer, reward, "Successful proposal");
    }

    /**
     * @notice Emergency function to revoke vesting for a beneficiary
     * @dev Only callable by the owner
     * @param beneficiary Address of the beneficiary
     */
    function revokeVesting(address beneficiary) external onlyOwner {
        VestingSchedule storage schedule = vestingSchedules[beneficiary];
        require(
            schedule.totalAllocation > 0,
            "No vesting schedule for this address"
        );
        require(!schedule.revoked, "Vesting schedule already revoked");

        uint256 vestedAmount = calculateVestedAmount(beneficiary);
        uint256 unvested = schedule.totalAllocation - vestedAmount;

        if (unvested > 0) {
            uint256 fee = unvested / 1000; // 0.1% fee
            uint256 amountToRefund = unvested - fee;
            require(
                token.transfer(owner(), amountToRefund),
                "Refund transfer failed"
            );
        }

        schedule.revoked = true;
        emit VestingRevoked(beneficiary);
    }

    /**
     * @notice Distribute tokens directly to recipients (for public/instant allocations)
     * @dev Only callable by the owner
     * @param recipients Array of recipient addresses
     * @param amounts Array of token amounts
     * @param category Allocation category
     */
    function distributeTokens(
        address[] calldata recipients,
        uint256[] calldata amounts,
        AllocationCategory category
    ) external onlyOwner {
        require(recipients.length == amounts.length, "Array length mismatch");
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        require(
            categoryAllocated[category] + totalAmount <=
                categoryLimits[category],
            "Exceeds category limit"
        );
        categoryAllocated[category] += totalAmount;
        for (uint256 i = 0; i < recipients.length; i++) {
            require(
                token.transfer(recipients[i], amounts[i]),
                "Transfer failed"
            );
            // Add delegation
            if (
                amounts[i] > 0 &&
                recipients[i] != owner() &&
                recipients[i] != address(this)
            ) {
                ERC20Votes(address(token)).delegate(recipients[i]);
            }
        }
    }

    /**
     * @notice Get vesting schedule info for a beneficiary
     * @param beneficiary Address to query
     * @return totalAllocation Total tokens allocated
     * @return claimedAmount Amount already claimed
     * @return claimableAmount Amount currently claimable
     * @return vestedAmount Amount currently vested
     * @return startTime Vesting start timestamp
     * @return cliffEnd Timestamp when cliff ends
     * @return vestingEnd Timestamp when vesting ends
     * @return revoked Whether the vesting is revoked
     */
    function getVestingInfo(
        address beneficiary
    )
        external
        view
        returns (
            uint256 totalAllocation,
            uint256 claimedAmount,
            uint256 claimableAmount,
            uint256 vestedAmount,
            uint256 startTime,
            uint256 cliffEnd,
            uint256 vestingEnd,
            bool revoked
        )
    {
        VestingSchedule memory schedule = vestingSchedules[beneficiary];
        return (
            schedule.totalAllocation,
            schedule.claimed,
            getClaimableAmount(beneficiary),
            calculateVestedAmount(beneficiary),
            schedule.startTime,
            schedule.startTime + schedule.cliffDuration,
            schedule.startTime + schedule.vestingDuration,
            schedule.revoked
        );
    }

    /**
     * @notice Get allocation info for a category
     * @param category Allocation category
     * @return limit Maximum tokens for the category
     * @return allocated Tokens already allocated
     * @return remaining Tokens remaining for allocation
     */
    function getCategoryInfo(
        AllocationCategory category
    )
        external
        view
        returns (uint256 limit, uint256 allocated, uint256 remaining)
    {
        uint256 categoryLimit = categoryLimits[category];
        uint256 categoryAlloc = categoryAllocated[category];
        return (categoryLimit, categoryAlloc, categoryLimit - categoryAlloc);
    }

    /**
     * @notice Emergency withdraw unallocated tokens to the owner
     * @dev Only callable by the owner
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(token.transfer(owner(), amount), "Transfer failed");
        emit TokensClaimed(owner(), amount);
    }
}
