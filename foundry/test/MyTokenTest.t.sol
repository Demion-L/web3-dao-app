// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title MyToken Test Suite
 * @dev This test suite verifies the functionality of the MyToken contract
 * @notice This is a comprehensive test suite for an ERC20Votes token with governance capabilities
 */
import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "contracts/token/MyToken.sol";

contract MyTokenTest is Test {
    // State variables that will be used across all tests
    MyToken public myToken; // The token contract we're testing
    address public owner; // The deployer of the contract
    address public addr1; // Test account 1
    address public addr2; // Test account 2

    /**
     * @dev This function runs before each test
     * @notice Sets up a fresh contract instance and test accounts for each test
     */
    function setUp() public {
        // Create deterministic test addresses
        owner = makeAddr("owner");
        addr1 = makeAddr("addr1");
        addr2 = makeAddr("addr2");

        // Deploy a new contract instance before each test
        vm.startPrank(owner); // Impersonate the owner
        myToken = new MyToken();
        vm.stopPrank(); // Stop impersonating
    }

    /**
     * @dev Tests the initial deployment state of the contract
     * @notice Verifies that the total supply is correct and all tokens are owned by the deployer
     */
    function test_Deployment() public view {
        // Check if total supply matches the maximum supply
        assertEq(myToken.totalSupply(), myToken.s_maxSupply());

        // Verify that owner has all tokens
        assertEq(myToken.balanceOf(owner), myToken.s_maxSupply());
    }

    /**
     * @dev Tests basic token transfer functionality
     * @notice Verifies that tokens can be transferred between accounts
     */
    function test_Transfer() public {
        uint256 amount = 50;

        // Transfer from owner to addr1
        vm.startPrank(owner);
        myToken.transfer(addr1, amount);
        vm.stopPrank();

        // Verify addr1 received the tokens
        assertEq(myToken.balanceOf(addr1), amount);

        // Transfer from addr1 to addr2
        vm.startPrank(addr1);
        myToken.transfer(addr2, amount);
        vm.stopPrank();

        // Verify addr2 received the tokens
        assertEq(myToken.balanceOf(addr2), amount);
    }

    /**
     * @dev Tests that transfers fail when sender has insufficient balance
     * @notice Verifies the contract's balance checking mechanism
     */
    function test_RevertWhen_TransferInsufficientBalance() public {
        // Try to transfer from addr1 (who has 0 tokens) to owner
        vm.startPrank(addr1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC20InsufficientBalance(address,uint256,uint256)",
                addr1,
                0,
                1
            )
        );
        myToken.transfer(owner, 1);
        vm.stopPrank();
    }

    /**
     * @dev Tests the delegation mechanism
     * @notice Verifies that token holders can delegate their voting power
     */
    function test_Delegation() public {
        uint256 amount = 100;

        // First transfer tokens to addr1
        vm.startPrank(owner);
        myToken.transfer(addr1, amount);
        vm.stopPrank();

        // Move to next block for transfer to settle
        vm.roll(block.number + 1);

        // addr1 delegates their voting power to addr2
        vm.startPrank(addr1);
        myToken.delegate(addr2);
        vm.stopPrank();

        // Move to next block for delegation to settle
        vm.roll(block.number + 1);

        // Verify addr2 has the delegated voting power
        assertEq(myToken.getVotes(addr2), amount);
    }

    /**
     * @dev Tests a complex scenario of transfer and delegation
     * @notice Verifies that voting power is correctly handled after transfers
     */
    function test_TransferAndDelegation() public {
        uint256 amount = 1000;

        // Transfer tokens to addr1
        vm.startPrank(owner);
        myToken.transfer(addr1, amount);
        vm.stopPrank();

        // Move to next block for transfer to settle
        vm.roll(block.number + 1);

        // addr1 delegates to addr2
        vm.startPrank(addr1);
        myToken.delegate(addr2);
        vm.stopPrank();

        // Move to next block for delegation to settle
        vm.roll(block.number + 1);

        // addr1 transfers tokens to addr2
        vm.startPrank(addr1);
        myToken.transfer(addr2, amount);
        vm.stopPrank();

        // Move to next block for transfer to settle
        vm.roll(block.number + 1);

        // ✅ Now addr2 must delegate to themselves to have voting power
        vm.startPrank(addr2);
        myToken.delegate(addr2);
        vm.stopPrank();

        // Move to next block for delegation to settle
        vm.roll(block.number + 1);

        // ✅ Now addr2 has votes
        assertEq(myToken.getVotes(addr2), amount);
    }

    /**
     * @dev Tests delegation after a transfer
     * @notice Verifies that voting power is correctly updated after token transfers
     */
    function test_DelegationAfterTransfer() public {
        uint256 amount = 100;

        // Transfer tokens to addr1
        vm.startPrank(owner);
        myToken.transfer(addr1, amount);
        vm.stopPrank();

        // Move to next block for transfer to settle
        vm.roll(block.number + 1);

        // addr1 delegates to addr2
        vm.startPrank(addr1);
        myToken.delegate(addr2);
        vm.stopPrank();

        // Move to next block for delegation to settle
        vm.roll(block.number + 1);

        // Verify delegation was successful
        assertEq(myToken.getVotes(addr2), amount);
    }
}
