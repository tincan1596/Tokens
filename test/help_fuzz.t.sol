// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {HELP} from "../src/imports/help.sol";

contract HELPFuzzTest is Test {
    HELP token;
    address owner = address(this);

    function setUp() public {
        token = new HELP(1000);
    }

    /*//////////////////////////////////////////////////////////////
                              TRANSFER TESTS
    //////////////////////////////////////////////////////////////*/

    // Fuzz direct transfers from owner to random recipient
    function testFuzz_Transfer(uint96 amount, address to) public {
        vm.assume(to != address(0));
        amount = uint96(bound(amount, 0, token.balanceOf(owner)));

        token.transfer(to, amount);
        assertEq(token.balanceOf(to), amount);
    }

    // Fuzz transfers from random sender to recipient
    function testFuzz_TransferFromRandomSender(address sender, address recipient, uint96 amount) public {
        vm.assume(sender != address(0) && recipient != address(0) && sender != recipient);

        // Give sender some tokens
        token.mint(sender, 10000);

        uint96 balance = uint96(token.balanceOf(sender));
        amount = uint96(bound(amount, 0, balance));

        vm.prank(sender);
        token.transfer(recipient, amount);

        assertEq(token.balanceOf(recipient), amount);
    }

    /*//////////////////////////////////////////////////////////////
                          APPROVE + TRANSFERFROM TESTS
    //////////////////////////////////////////////////////////////*/

    function testFuzz_ApproveAndTransferFrom(uint96 amount, address spender, address recipient) public {
        vm.assume(spender != address(0) && spender != owner && spender != recipient);
        vm.assume(recipient != address(0) && recipient != owner && recipient != spender);

        amount = uint96(bound(amount, 0, token.balanceOf(owner)));

        token.approve(spender, amount);
        assertEq(token.allowance(owner, spender), amount);

        vm.prank(spender);
        token.transferFrom(owner, recipient, amount);

        assertEq(token.balanceOf(recipient), amount);
        assertEq(token.allowance(owner, spender), 0);
    }

    /*//////////////////////////////////////////////////////////////
                              MINT TESTS
    //////////////////////////////////////////////////////////////*/

    // Owner can mint to any address
    function testFuzz_MintByOwner(address to, uint96 amount) public {
        vm.assume(to != address(0));

        token.mint(to, amount);
        assertEq(token.balanceOf(to), amount);
    }

    // Non-owner cannot mint
    function testFuzz_RevertWhen_NonOwnerMints(address nonOwner, address to, uint96 amount) public {
        vm.assume(nonOwner != owner);
        vm.assume(to != address(0));

        vm.prank(nonOwner);
        vm.expectRevert();
        token.mint(to, amount);
    }

    /*//////////////////////////////////////////////////////////////
                              BURN TESTS
    //////////////////////////////////////////////////////////////*/

    // Burn within balance should succeed
    function testFuzz_BurnWithinBalance(address to, uint96 amount) public {
        vm.assume(to != address(0));

        token.mint(to, amount);
        vm.assume(amount > 0);

        token.burn(to, amount / 2);
        assertEq(token.balanceOf(to), amount - (amount / 2));
    }

    // Burn more than balance should revert
    function testFuzz_RevertWhen_BurningMoreThanBalance(address to, uint96 amount) public {
        vm.assume(to != address(0));
        vm.assume(amount > 0);

        token.mint(to, amount / 2); // Mint less than requested burn

        vm.expectRevert();
        token.burn(to, amount);
    }

    // Non-owner cannot burn
    function testFuzz_RevertWhen_NonOwnerBurns(address nonOwner, address to, uint96 amount) public {
        vm.assume(nonOwner != owner);
        vm.assume(to != address(0));

        token.mint(to, amount);

        vm.prank(nonOwner);
        vm.expectRevert();
        token.burn(to, amount);
    }
}
