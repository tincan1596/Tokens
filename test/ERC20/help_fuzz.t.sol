// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {HELP} from "../../src/ERC20/imports/help.sol";

contract HELPFuzzTest is Test {
    HELP token;
    address owner = address(this);

    function setUp() public {
        token = new HELP(1000 * 1e18);
    }

    function testFuzz_Transfer(uint96 amount, address to) public {
        vm.assume(to != address(0));
        amount = uint96(bound(amount, 0, token.balanceOf(owner)));

        token.transfer(to, amount);
        assertEq(token.balanceOf(to), amount);
    }

    function testFuzz_ApproveAndTransferfrom(uint96 amount, address spender, address recipient) public {
        amount = uint96(bound(amount, 0, token.balanceOf(owner)));
        vm.assume(spender != address(0) && spender != address(this) && spender != recipient);
        vm.assume(recipient != address(0) && recipient != address(this) && recipient != spender);

        token.approve(spender, amount);
        assertEq(token.allowance(owner, spender), amount);

        vm.prank(spender);
        token.transferFrom(owner, recipient, amount);
        assertEq(token.balanceOf(recipient), amount);
        assertEq(token.allowance(owner, spender), 0);
    }
}
