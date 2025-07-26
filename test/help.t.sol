// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {HELP} from "../src/Imports/help.sol";

contract HELPTest is Test {
    HELP help;
    address owner = address(this); // Test contract acts as owner
    address user1 = address(0x123);
    address user2 = address(0x456);

    function setUp() public {
        help = new HELP(1_000_000 * 10 ** 18); // Deploy token before each test
    }

    //Test initial supply assignment
    function test_InitialSupply() public view {
        uint256 supply = help.totalSupply();
        uint256 ownerBalance = help.balanceOf(owner);
        assertEq(ownerBalance, supply, "Initial supply should belong to owner");
    }

    //Test transfer functionality
    function test_Transfer() public {
        help.transfer(user1, 100 * 10 ** 18);
        assertEq(help.balanceOf(user1), 100 * 10 ** 18, "User1 should receive tokens");
    }

    //Test approve and transferFrom
    function test_Approval() public {
        help.approve(user1, 200 * 10 ** 18);
        vm.prank(user1); // simulate user1 calling transferFrom
        help.transferFrom(owner, user2, 50 * 10 ** 18);
        assertEq(help.balanceOf(user2), 50 * 10 ** 18, "User2 should get 50 tokens");
    }

    //Test mint (only owner can mint)
    function test_MintByOwner() public {
        help.mint(user1, 500 * 10 ** 18);
        assertEq(help.balanceOf(user1), 500 * 10 ** 18, "Minted tokens not assigned");
    }

    //Test revert when non-owner tries to mint
    function test_RevertWhen_NonOwnerMints() public {
        vm.prank(user1); // make user1 the caller
        vm.expectRevert(); // expect revert because user1 is not owner
        help.mint(user1, 500 * 10 ** 18);
    }

    //Test burn functionality
    function test_BurnTokens() public {
        uint256 balanceBefore = help.balanceOf(owner);
        help.burn(owner, 100 * 10 ** 18);
        uint256 balanceAfter = help.balanceOf(owner);
        assertEq(balanceBefore - balanceAfter, 100 * 10 ** 18, "Burned amount mismatch");
    }
}
