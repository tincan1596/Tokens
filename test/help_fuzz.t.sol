// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {HELP} from "../src/imports/help.sol";

contract HELPFuzzTest is Test {
    HELP token;
    address owner = address(this);

    function setUp() public {
        token = new HELP(1000 * 1e18);
    }

    function testFuzz_Transfer(uint96 amount, address to) public {
        vm.assume(to != address(0));
        vm.assume(amount <= token.balanceOf(owner));

        token.transfer(to, amount);
        assertEq(token.balanceOf(to), amount);
    }

    function testFuzz_ApproveAndTransferFrom(uint96 amount) public {
        vm.assume(amount <= token.balanceOf(owner));

        token.approve(address(this), amount);
        token.transferFrom(owner, address(0xBEEF), amount);

        assertEq(token.balanceOf(address(0xBEEF)), amount);
    }
}
