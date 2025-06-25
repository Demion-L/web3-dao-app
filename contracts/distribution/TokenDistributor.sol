// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TokenDistributor
 * @dev Manages token distribution with vesting schedules for different allocation categories
 */

contract TokenDistributor is Ownable, ReentrancyGuard {
    IERC20 public immutable token;

    // Allocation categories of token recipients
    // These categories represent different groups of token holders
    enum AllocationCategory {
        TREASURY,
        FOUNDING_MEMBERS,
        CORE_TEAM,
        COMMUNITY_INCENTIVES,
        PUBLIC_DISTRIBUTION,
        LIQUIDITY_PARTNERSHIPS
    }

    /**  
     * Each beneficiary gets a VestingSchedule that defines:
    - totalAlocation: Total tokens assigned.
    - cliffDuration: How long (in seconds/months) before tokens start unlocking.
    - vestingDuration: How long it takes to fully vest.
    - startTime: When vesting starts.
    - claimed: How many tokens the user has already claimed.
    - revoked: Whether the schedule is canceled. 
    */
    struct VestingSchedule {
        uint256 totalAlocation;
        uint256 cliffDuration;
        uint256 vestingDuration;
        uint256 startTime;
        uint256 claimed;
        bool revoked;
    }

    /**
        categoryLimits: How many tokens each group can get.
        categoryAllocated: How many tokens each group has already been given.
        VestingSchedules: Links a user address to their vesting info.
     */
    mapping(AllocationCategory => uint256) public categoryLimits;
    mapping(AllocationCategory => uint256) public categoryAllocated;
    mapping(address => VestingSchedule) public VestingSchedules;

    // This is additional tracking for governance participation.
    // These mappings support bonus distributions for on-chain activity (voting, proposing, etc.).
    mapping(address => uint256) public governanceRewards;
    mapping(address => uint256) public lastVoteTime;
    mapping(address => uint256) public proposalRewards;

    // Events
    event VestingScheduleCreated(
        address indexed beneficiary,
        uint256 amount,
        uint256 startTime
    );

    event TokensClaimed(
        address indexed beneficiary,
        uint256 amount
    );

    event GovernanceRewardGranted(
        address indexed user,
        uint256 amount,
        string reason
    )

    event VestingRevoked(
        address indexed beneficiary
    )

    constructor(IERC20 _token, address initialOwner) Ownable(initialOwner) {
        token = _token;

          // Set category limits (based on 1M token supply)
        categoryLimits[AllocationCategory.TREASURY] = 400_000 * 10**18;
        categoryLimits[AllocationCategory.FOUNDING_MEMBERS] = 250_000 * 10**18;
        categoryLimits[AllocationCategory.CORE_TEAM] = 150_000 * 10**18;
        categoryLimits[AllocationCategory.COMMUNITY_INCENTIVES] = 100_000 * 10**18;
        categoryLimits[AllocationCategory.PUBLIC_DISTRIBUTION] = 50_000 * 10**18;
        categoryLimits[AllocationCategory.LIQUIDITY_PARTNERSHIPS] = 50_000 * 10**18;
    }

      /**
     * @dev Create vesting schedule for beneficiary
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
    ) external onlyOwner {
        require(beneficiary != address(0), "Invalid beneficiary address");
        require(allocation > 0, "Allocation must be greater than zero");
        require(vestingSchedules[beneficiary].totalAlocation ==0, "Vesting schedule already exists for this address");
    

    // Check category limits
    require(categoryAllocated[category] + allocation <= categoryLimits[category], "Category allocation limit exceeded");

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
     * @dev Batch create vesting schedules. This is a helper to create multiple vesting schedules at once.
     */
    function batchCreateVestingSchedules(
        address[] calldata beneficiaries,
        uint256[] calldata allocations,
        AllocationCategory category,
        uint256 cliffMonths,
        uint256 vestingMonths
    ) external onlyOwner {
        require(beneficiaries.length == allocations.length, "Beneficiaries and allocations length mismatch");
        
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
     * @dev Calculate vested amount for a beneficiary
     * @param beneficiary Address to check
     * @return vestedAmount Amount of tokens vested
     */
    function calculateVestedAmount(address beneficiary) public view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[beneficiary];
        
        // Check if vesting schedule exists
        if (schedule.revoked || schedule.totalAllocation == 0) {
            return 0;
        }
        
        // Get current time
        uint256 currentTime = block.timestamp;
        
        // Before cliff
        // If the current time is before the cliff ends, no tokens are vested
        if (currentTime < schedule.startTime + schedule.cliffDuration) {
            return 0;
        }
        
        // After full vesting
        if (currentTime >= schedule.startTime + schedule.vestingDuration) {
            return schedule.totalAllocation;
        }
        
        // During vesting period
        // Calculate the vested amount based on time elapsed since cliff end
        // Vested time is the time since the cliff ended
        // Vesting time is the total vesting duration minus the cliff duration
        // Vested amount is proportional to the time elapsed since cliff end
        uint256 vestedTime = currentTime - schedule.startTime - schedule.cliffDuration;
        uint256 vestingTime = schedule.vestingDuration - schedule.cliffDuration;
        
        // Calculate vested amount
        if (vestingTime == 0) {
            return 0; // Avoid division by zero
        }
        // Return the proportion of total allocation that is vested
        return (schedule.totalAllocation * vestedTime) / vestingTime;
    }

     
    /**
     * @dev Get claimable amount for beneficiary
     * @param beneficiary Address to check
     * @return claimableAmount Amount that can be claimed
     */
    function getClaimableAmount(address beneficiary) public view returns (uint256) {
        // Calculate the vested amount
        // and subtract the already claimed amount
        require(beneficiary != address(0), "Invalid beneficiary address");
        require(vestingSchedules[beneficiary].totalAllocation > 0, "No vesting schedule for this address");
        require(!vestingSchedules[beneficiary].revoked, "Vesting schedule revoked");

        uint256 vestedAmount = calculateVestedAmount(beneficiary);
        uint256 claimed = vestingSchedules[beneficiary].claimed;
        
        return vestedAmount > claimed ? vestedAmount - claimed : 0;
    }
    
    /**
     * @dev Claim vested tokens
     */
    function claimVestedTokens() external nonReentrant {
        uint256 claimableAmount = getClaimableAmount(msg.sender);
        require(claimableAmount > 0, "No tokens to claim");
        
        vestingSchedules[msg.sender].claimed += claimableAmount;
        
        require(token.transfer(msg.sender, claimableAmount), "Transfer failed");
        
        emit TokensClaimed(msg.sender, claimableAmount);
    }
    
    /**
     * @dev Grant governance participation rewards
     * @param user Address of the user
     * @param amount Reward amount
     * @param reason Reason for the reward
     */
    function grantGovernanceReward(
        address user,
        uint256 amount,
        string calldata reason
    ) external onlyOwner {
        require(
            categoryAllocated[AllocationCategory.COMMUNITY_INCENTIVES] + amount <= 
            categoryLimits[AllocationCategory.COMMUNITY_INCENTIVES],
            "Exceeds community incentives limit"
        );
        
        governanceRewards[user] += amount;
        categoryAllocated[AllocationCategory.COMMUNITY_INCENTIVES] += amount;
        
        require(token.transfer(user, amount), "Transfer failed");
        
        emit GovernanceRewardGranted(user, amount, reason);
    }
    
    /**
     * @dev Batch reward governance participants
     */
    function batchGrantGovernanceRewards(
        address[] calldata users,
        uint256[] calldata amounts,
        string calldata reason
    ) external onlyOwner {
        require(users.length == amounts.length, "Array length mismatch");
        
        for (uint256 i = 0; i < users.length; i++) {
            grantGovernanceReward(users[i], amounts[i], reason);
        }
    }
    
    /**
     * @dev Reward voting participation (called by governance contract)
     */
    function rewardVoting(address voter) external onlyOwner {
        uint256 reward = 10 * 10**18; // 10 MTK per vote
        
        // Limit to one reward per day per user
        require(block.timestamp > lastVoteTime[voter] + 1 days, "Already rewarded today");
        
        lastVoteTime[voter] = block.timestamp;
        grantGovernanceReward(voter, reward, "Voting participation");
    }
    
    /**
     * @dev Reward successful proposal creation
     */
    function rewardProposal(address proposer) external onlyOwner {
        uint256 reward = 100 * 10**18; // 100 MTK per successful proposal
        
        proposalRewards[proposer] += reward;
        grantGovernanceReward(proposer, reward, "Successful proposal");
    }
    
    /**
     * @dev Emergency function to revoke vesting (only in extreme cases)
     */
    function revokeVesting(address beneficiary) external onlyOwner {
        require(!vestingSchedules[beneficiary].revoked, "Already revoked");
        
        vestingSchedules[beneficiary].revoked = true;
        
        emit VestingRevoked(beneficiary);
    }
    
    /**
     * @dev Direct token distribution for public/instant allocations
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
            categoryAllocated[category] + totalAmount <= categoryLimits[category],
            "Exceeds category limit"
        );
        
        categoryAllocated[category] += totalAmount;
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transfer(recipients[i], amounts[i]), "Transfer failed");
        }
    }
    
    /**
     * @dev Get vesting schedule info for a beneficiary
     */
    function getVestingInfo(address beneficiary) external view returns (
        uint256 totalAllocation,
        uint256 claimedAmount,
        uint256 claimableAmount,
        uint256 vestedAmount,
        uint256 startTime,
        uint256 cliffEnd,
        uint256 vestingEnd,
        bool revoked
    ) {
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
     * @dev Get category allocation info
     */
    function getCategoryInfo(AllocationCategory category) external view returns (
        uint256 limit,
        uint256 allocated,
        uint256 remaining
    ) {
        uint256 categoryLimit = categoryLimits[category];
        uint256 categoryAlloc = categoryAllocated[category];
        
        return (
            categoryLimit,
            categoryAlloc,
            categoryLimit - categoryAlloc
        );
    }
    
    /**
     * @dev Emergency withdraw function (only for unallocated tokens)
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(token.transfer(owner(), amount), "Transfer failed");
    }
}

    
        

