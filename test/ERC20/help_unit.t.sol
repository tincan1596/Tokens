// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {HELP} from "../../src/ERC20/imports/help.sol";

contract HELPUnitTest is Test {
    HELP token;
    address owner = address(this);
    address user1 = address(0x111);
    address user2 = address(0x222);

    function setUp() public {
        token = new HELP(1000 * 1e18);
    }

    // Initial Supply
    function test_InitialSupplyAssignedToOwner() public view {
        assertEq(token.totalSupply(), 1000 * 1e18);
        assertEq(token.balanceOf(owner), 1000 * 1e18);
    }

    // transfer()
    function test_TransferTokens() public {
        token.transfer(user1, 100 * 1e18);
        assertEq(token.balanceOf(user1), 100 * 1e18);
        assertEq(token.balanceOf(owner), 900 * 1e18);
    }

    function test_RevertWhen_TransferExceedsBalance() public {
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, 1);
    }

    // approve() + allowance()
    function test_ApproveAndAllowance() public {
        token.approve(user1, 500 * 1e18);
        assertEq(token.allowance(owner, user1), 500 * 1e18);
    }

    // transferFrom()
    function test_TransferFromWithApproval() public {
        token.approve(user1, 200 * 1e18);

        vm.prank(user1);
        token.transferFrom(owner, user2, 100 * 1e18);

        assertEq(token.balanceOf(user2), 100 * 1e18);
        assertEq(token.allowance(owner, user1), 100 * 1e18);
    }

    function test_RevertWhen_TransferFromWithoutApproval() public {
        vm.prank(user1);
        vm.expectRevert();
        token.transferFrom(owner, user2, 10 * 1e18);
    }

    // Mint & Burn by Owner
    function test_MintByOwner() public {
        token.mint(user1, 100 * 1e18);
        assertEq(token.balanceOf(user1), 100 * 1e18);
    }

    function test_BurnByOwner() public {
        token.mint(user1, 200 * 1e18);
        token.burn(user1, 50 * 1e18);
        assertEq(token.balanceOf(user1), 150 * 1e18);
    }
}
