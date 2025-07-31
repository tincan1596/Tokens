// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {HELP} from "../src/imports/help.sol";

contract HELPUnitTest is Test {
    HELP token;
    address owner = address(this);
    address user1 = address(0x111);
    address user2 = address(0x222);

    function setUp() public {
        token = new HELP(1000);
    }

    // Initial Supply
    function test_InitialSupplyAssignedToOwner() public view {
        assertEq(token.totalSupply(), 1000);
        assertEq(token.balanceOf(owner), 1000);
    }

    // transfer()
    function test_TransferTokens() public {
        token.transfer(user1, 100);
        assertEq(token.balanceOf(user1), 100);
        assertEq(token.balanceOf(owner), 900);
    }

    function test_RevertWhen_TransferExceedsBalance() public {
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, 1);
    }

    // approve() + allowance()
    function test_ApproveAndAllowance() public {
        token.approve(user1, 500);
        assertEq(token.allowance(owner, user1), 500);
    }

    // transferFrom()
    function test_TransferFromWithApproval() public {
        token.approve(user1, 200);

        vm.prank(user1);
        token.transferFrom(owner, user2, 100);

        assertEq(token.balanceOf(user2), 100);
        assertEq(token.allowance(owner, user1), 100);
    }

    function test_RevertWhen_TransferFromWithoutApproval() public {
        vm.prank(user1);
        vm.expectRevert();
        token.transferFrom(owner, user2, 10);
    }

    // Mint & Burn by Owner
    function test_MintByOwner() public {
        token.mint(user1, 100);
        assertEq(token.balanceOf(user1), 100);
    }

    function test_BurnByOwner() public {
        token.mint(user1, 200);
        token.burn(user1, 50);
        assertEq(token.balanceOf(user1), 150);
    }

    // Test that non-owner cannot mint or burn
    function test_RevertWhen_NonOwnerMints() public {
        vm.prank(user1);
        vm.expectRevert();
        token.mint(user1, 100);
    }

    function test_RevertWhen_NonOwnerBurns() public {
        token.mint(user1, 100);
        vm.prank(user1);
        vm.expectRevert();
        token.burn(user1, 50);
    }

    // Transfer 0 tokens should succeed
    function test_TransferZeroTokens() public {
        token.transfer(user1, 0);
        assertEq(token.balanceOf(user1), 0);
    }

    // Approve 0 tokens should succeed
    function test_ApproveZeroTokens() public {
        token.approve(user1, 0);
        assertEq(token.allowance(owner, user1), 0);
    }

    // Burn more than balance should revert
    function test_RevertWhen_BurningMoreThanBalance() public {
        token.mint(user1, 50);
        vm.expectRevert();
        token.burn(user1, 100);
    }
}
