// MyToken.t.sol
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/token/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address owner = address(1);

    function setUp() public {
        token = new MyToken();
        vm.prank(owner);
        token.transferOwnership(owner);
    }

    function testMintRestrictedToOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(2));
        token.mint(address(3), 1e18);
    }

    function testMintSuccess() public {
        vm.startPrank(owner);
        token.mint(address(4), 1e18);
        assertEq(token.balanceOf(address(4)), 1e18);
        vm.stopPrank();
    }
}
