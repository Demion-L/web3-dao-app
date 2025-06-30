// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "contracts/token/MyToken.sol";
import {TokenDistributor} from "contracts/distribution/TokenDistributor.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TokenDistributorTest is Test {
    // Contract instances
    MyToken public myToken;
    TokenDistributor public distributor;

    // Test addresses
    address public owner;
    address public beneficiary1;
    address public beneficiary2;
    address public outsider;

    function setUp() public {
        // Create deterministic test addresses
        owner = makeAddr("owner");
        beneficiary1 = makeAddr("beneficiary1");
        beneficiary2 = makeAddr("beneficiary2");
        outsider = makeAddr("outsider");

        // Deploy MyToken and TokenDistributor
        vm.startPrank(owner);
        myToken = new MyToken(owner);
        distributor = new TokenDistributor(myToken, owner);
        vm.stopPrank();
    }

    /**
     * TODO: createVestingSchedule
     * TODO: batchCreateVestingSchedules
     * TODO: calculateVestedAmount
     * TODO: getClaimableAmount
     * TODO: claimVestedTokens
     * TODO: grantGovernanceReward
     * TODO: batchGrantGovernanceRewards
     * TODO: rewardVoting
     * TODO: rewardProposal
     * TODO: revokeVesting
     * TODO: distributeTokens
     * TODO: getVestingInfo
     * TODO: getCategoryInfo
     * TODO: emergencyWithdraw
     */

    function test_createVestingSchedule_WorksForOwner() public {
        uint256 allocation = 1000e18;
        uint256 cliffMonths = 2;
        uint256 vestingMonths = 12;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;

        // Fund the distributor with enough tokens
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        vm.stopPrank();

        // Create vesting schedule as owner
        vm.prank(owner);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            cliffMonths,
            vestingMonths
        );

        // Check vesting schedule
        (
            uint256 totalAllocation,
            uint256 claimedAmount,
            ,
            ,
            ,
            ,
            ,
            bool revoked
        ) = distributor.getVestingInfo(beneficiary1);
        assertEq(totalAllocation, allocation);
        assertEq(claimedAmount, 0);
        assertEq(revoked, false);
        assertEq(distributor.categoryAllocated(category), allocation);
        // Cliff and vesting times are checked indirectly via startTime, can add more checks if needed
    }

    function test_createVestingSchedule_RevertsIfNotOwner() public {
        uint256 allocation = 1000e18;
        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                outsider
            )
        );
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            1,
            12
        );
    }

    function test_createVestingSchedule_RevertsOnDuplicate() public {
        uint256 allocation = 1000e18;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation * 2);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            1,
            12
        );
        vm.expectRevert("Vesting schedule already exists for this address");
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            1,
            12
        );
        vm.stopPrank();
    }

    function test_createVestingSchedule_RevertsOnZeroAllocation() public {
        vm.prank(owner);
        vm.expectRevert("Allocation must be greater than zero");
        distributor.createVestingSchedule(
            beneficiary1,
            0,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            1,
            12
        );
    }

    function test_createVestingSchedule_RevertsOnCategoryLimit() public {
        uint256 allocation = distributor.categoryLimits(
            TokenDistributor.AllocationCategory.CORE_TEAM
        ) + 1;
        vm.prank(owner);
        vm.expectRevert("Category allocation limit exceeded");
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            1,
            12
        );
    }

    function test_batchCreateVestingSchedules_WorksForOwner() public {
        uint256[] memory allocations = new uint256[](2);
        allocations[0] = 1000e18;
        allocations[1] = 2000e18;
        address[] memory beneficiaries = new address[](2);
        beneficiaries[0] = beneficiary1;
        beneficiaries[1] = beneficiary2;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        uint256 cliffMonths = 1;
        uint256 vestingMonths = 12;
        uint256 total = allocations[0] + allocations[1];

        // Fund the distributor with enough tokens
        vm.startPrank(owner);
        myToken.transfer(address(distributor), total);
        distributor.batchCreateVestingSchedules(
            beneficiaries,
            allocations,
            category,
            cliffMonths,
            vestingMonths
        );
        vm.stopPrank();

        // Check both vesting schedules
        (uint256 alloc1, , , , , , , ) = distributor.getVestingInfo(
            beneficiary1
        );
        (uint256 alloc2, , , , , , , ) = distributor.getVestingInfo(
            beneficiary2
        );
        assertEq(alloc1, allocations[0]);
        assertEq(alloc2, allocations[1]);
        assertEq(distributor.categoryAllocated(category), total);
    }

    function test_batchCreateVestingSchedules_RevertsIfNotOwner() public {
        uint256[] memory allocations = new uint256[](1);
        allocations[0] = 1000e18;
        address[] memory beneficiaries = new address[](1);
        beneficiaries[0] = beneficiary1;
        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                outsider
            )
        );
        distributor.batchCreateVestingSchedules(
            beneficiaries,
            allocations,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            1,
            12
        );
    }

    function test_batchCreateVestingSchedules_RevertsOnLengthMismatch() public {
        uint256[] memory allocations = new uint256[](2);
        allocations[0] = 1000e18;
        allocations[1] = 2000e18;
        address[] memory beneficiaries = new address[](1);
        beneficiaries[0] = beneficiary1;
        vm.prank(owner);
        vm.expectRevert("Beneficiaries and allocations length mismatch");
        distributor.batchCreateVestingSchedules(
            beneficiaries,
            allocations,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            1,
            12
        );
    }

    function test_batchCreateVestingSchedules_RevertsOnCategoryLimit() public {
        uint256[] memory allocations = new uint256[](2);
        allocations[0] = distributor.categoryLimits(
            TokenDistributor.AllocationCategory.CORE_TEAM
        );
        allocations[1] = 1;
        address[] memory beneficiaries = new address[](2);
        beneficiaries[0] = beneficiary1;
        beneficiaries[1] = beneficiary2;
        vm.prank(owner);
        vm.expectRevert("Category allocation limit exceeded");
        distributor.batchCreateVestingSchedules(
            beneficiaries,
            allocations,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            1,
            12
        );
    }

    function test_batchCreateVestingSchedules_RevertsOnZeroAllocation() public {
        uint256[] memory allocations = new uint256[](2);
        allocations[0] = 0;
        allocations[1] = 1000e18;
        address[] memory beneficiaries = new address[](2);
        beneficiaries[0] = beneficiary1;
        beneficiaries[1] = beneficiary2;
        vm.prank(owner);
        // The first call to createVestingSchedule will revert on zero allocation
        vm.expectRevert("Allocation must be greater than zero");
        distributor.batchCreateVestingSchedules(
            beneficiaries,
            allocations,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            1,
            12
        );
    }

    function test_batchCreateVestingSchedules_RevertsOnDuplicateBeneficiary()
        public
    {
        uint256[] memory allocations = new uint256[](2);
        allocations[0] = 1000e18;
        allocations[1] = 2000e18;
        address[] memory beneficiaries = new address[](2);
        beneficiaries[0] = beneficiary1;
        beneficiaries[1] = beneficiary1; // duplicate
        vm.prank(owner);
        // The second call to createVestingSchedule will revert on duplicate
        vm.expectRevert("Vesting schedule already exists for this address");
        distributor.batchCreateVestingSchedules(
            beneficiaries,
            allocations,
            TokenDistributor.AllocationCategory.CORE_TEAM,
            1,
            12
        );
    }

    function test_calculateVestedAmount_NoScheduleOrRevoked() public {
        // No schedule: should return 0
        assertEq(distributor.calculateVestedAmount(beneficiary1), 0);

        // Create and then revoke
        uint256 allocation = 1000e18;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            1,
            12
        );
        distributor.revokeVesting(beneficiary1);
        vm.stopPrank();
        assertEq(distributor.calculateVestedAmount(beneficiary1), 0);
    }

    function test_calculateVestedAmount_BeforeCliff() public {
        uint256 allocation = 1000e18;
        uint256 cliffMonths = 2;
        uint256 vestingMonths = 12;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            cliffMonths,
            vestingMonths
        );
        vm.stopPrank();
        // Immediately after creation, before cliff
        assertEq(distributor.calculateVestedAmount(beneficiary1), 0);
    }

    function test_calculateVestedAmount_DuringVesting() public {
        uint256 allocation = 1200e18;
        uint256 cliffMonths = 2;
        uint256 vestingMonths = 12;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            cliffMonths,
            vestingMonths
        );
        uint256 start = block.timestamp;
        vm.stopPrank();
        // Move to just after cliff
        vm.warp(start + cliffMonths * 30 days + 1);
        // Should be just starting to vest
        uint256 vested = distributor.calculateVestedAmount(beneficiary1);
        assertGt(vested, 0);
        assertLt(vested, allocation);
        // Move to halfway through vesting
        uint256 vestingPeriod = (vestingMonths - cliffMonths) * 30 days;
        vm.warp(start + cliffMonths * 30 days + vestingPeriod / 2);
        uint256 vestedHalf = distributor.calculateVestedAmount(beneficiary1);

        // The contract's logic appears to be: vested = allocation * (now - start) / (vestingMonths - cliffMonths)
        // With now = start + 7 months, and duration = 10 months, we expect 7/10 of the allocation.
        uint256 expectedVested = (allocation * 7) / 10;
        assertApproxEqAbs(vestedHalf, expectedVested, 1e16); // allow small rounding error
    }

    function test_calculateVestedAmount_AfterVesting() public {
        uint256 allocation = 1000e18;
        uint256 cliffMonths = 2;
        uint256 vestingMonths = 12;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            cliffMonths,
            vestingMonths
        );
        uint256 start = block.timestamp;
        vm.stopPrank();
        // Move to after full vesting
        vm.warp(start + vestingMonths * 30 days + 1);
        assertEq(distributor.calculateVestedAmount(beneficiary1), allocation);
    }

    function test_getClaimableAmount_RevertsIfNoSchedule() public {
        vm.expectRevert("No vesting schedule for this address");
        distributor.getClaimableAmount(beneficiary1);
    }

    function test_getClaimableAmount_RevertsIfRevoked() public {
        uint256 allocation = 1000e18;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            1,
            12
        );
        distributor.revokeVesting(beneficiary1);
        vm.stopPrank();
        vm.expectRevert("Vesting schedule revoked");
        distributor.getClaimableAmount(beneficiary1);
    }

    function test_getClaimableAmount_BeforeCliff() public {
        uint256 allocation = 1000e18;
        uint256 cliffMonths = 2;
        uint256 vestingMonths = 12;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            cliffMonths,
            vestingMonths
        );
        vm.stopPrank();
        assertEq(distributor.getClaimableAmount(beneficiary1), 0);
    }

    function test_getClaimableAmount_DuringVesting() public {
        uint256 allocation = 1200e18;
        uint256 cliffMonths = 2;
        uint256 vestingMonths = 12;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            cliffMonths,
            vestingMonths
        );
        uint256 start = block.timestamp;
        vm.stopPrank();
        // Move to halfway through vesting
        uint256 vestingPeriod = (vestingMonths - cliffMonths) * 30 days;
        vm.warp(start + cliffMonths * 30 days + vestingPeriod / 2);
        uint256 claimable = distributor.getClaimableAmount(beneficiary1);
        assertGt(claimable, 0);
        assertLt(claimable, allocation);
    }

    function test_getClaimableAmount_ZeroIfAllClaimed() public {
        uint256 allocation = 1000e18;
        uint256 cliffMonths = 1;
        uint256 vestingMonths = 2;
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;

        vm.startPrank(owner);
        // Fund the distributor with the full allocation
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            cliffMonths,
            vestingMonths
        );
        uint256 start = block.timestamp;
        vm.stopPrank();

        // Move to after full vesting
        vm.warp(start + vestingMonths * 30 days + 1);

        // Beneficiary claims all their vested tokens
        vm.prank(beneficiary1);
        distributor.claimVestedTokens();

        // Check that the beneficiary received the tokens
        assertEq(myToken.balanceOf(beneficiary1), allocation);
        // Check that the claimable amount is now zero
        assertEq(distributor.getClaimableAmount(beneficiary1), 0);
    }

    function test_getClaimableAmount_AfterPartialClaim() public {
        uint256 allocation = 1000e18;
        uint256 cliffMonths = 1;
        uint256 vestingMonths = 4; // Use 4 months for easier partial claim math
        TokenDistributor.AllocationCategory category = TokenDistributor
            .AllocationCategory
            .CORE_TEAM;
        vm.startPrank(owner);
        myToken.transfer(address(distributor), allocation);
        distributor.createVestingSchedule(
            beneficiary1,
            allocation,
            category,
            cliffMonths,
            vestingMonths
        );
        uint256 start = block.timestamp;
        vm.stopPrank();

        // Move to halfway through vesting (e.g., 2 months after cliff)
        vm.warp(start + (cliffMonths + 2) * 30 days + 1);

        // Beneficiary claims their vested tokens so far
        vm.prank(beneficiary1);
        distributor.claimVestedTokens();

        // After the first claim, the claimable amount should be very close to zero
        assertApproxEqAbs(
            distributor.getClaimableAmount(beneficiary1),
            0,
            1e14
        );

        // Move to after full vesting
        vm.warp(start + vestingMonths * 30 days + 1);

        // The remaining amount should now be claimable
        uint256 remainingClaimable = distributor.getClaimableAmount(
            beneficiary1
        );
        assertGt(remainingClaimable, 0);

        // The sum of the user's balance and remaining claimable should be the total allocation
        uint256 balance = myToken.balanceOf(beneficiary1);
        assertApproxEqAbs(balance + remainingClaimable, allocation, 1e14);
    }
}
