// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {HELP} from "../../src/ERC20/imports/help.sol";
import {Vm} from "forge-std/Vm.sol";

contract HELPHandler {
    HELP internal immutable token;
    Vm internal immutable vm;
    address internal immutable owner;

    address[] public actors;

    constructor(HELP _token, Vm _vm) {
        token = _token;
        vm = _vm;
        owner = _token.owner();

        // Add owner as first actor
        actors.push(owner);

        // Create 4 extra actors & distribute tokens
        for (uint256 i = 0; i < 4; i++) {
            address actor = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, i)))));
            actors.push(actor);

            // Mint 100 tokens to each new actor
            vm.prank(owner);
            token.mint(actor, 100 ether);
        }
    }

    // Manual bound (fallback for Foundry versions without vm.bound)
    function manualBound(uint256 value, uint256 min, uint256 max) internal pure returns (uint256) {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    function random() internal view returns (uint256) {
        uint256 index =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % actors.length;
        return index;
    }

    // Combined approve + transferFrom
    function callApproveAndTransferFrom(uint96 amount, address spender, address recipient) public {
        if (spender == address(0) || recipient == address(0) || spender == recipient) return;

        amount = uint96(manualBound(amount, 0, token.balanceOf(owner)));

        vm.prank(owner);
        token.approve(spender, amount);

        vm.prank(spender);
        token.transferFrom(owner, recipient, amount);
    }

    function callTransfer(uint96 amount, address to) public {
        if (to == address(0)) return;

        address sender = actors[random()];
        uint256 bal = token.balanceOf(sender);
        if (bal == 0) return;

        amount = uint96(manualBound(amount, 0, bal));

        vm.prank(sender);
        token.transfer(to, amount);
    }

    function callMint(uint96 amount, address to) public {
        if (to == address(0)) return;

        vm.prank(owner);
        token.mint(to, amount);
    }

    function callBurn(uint96 amount, address from) public {
        if (from == address(0)) return;

        uint256 bal = token.balanceOf(from);
        if (bal == 0) return;

        amount = uint96(manualBound(amount, 0, bal));

        vm.prank(owner);
        token.burn(from, amount);
    }

    function getActors() public view returns (address[] memory) {
        return actors;
    }
}
