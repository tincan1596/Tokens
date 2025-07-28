// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {HELP} from "../../src/ERC20/imports/help.sol";
import {Vm} from "forge-std/Vm.sol";

contract HelpTokenHandler {
    Vm internal immutable vm;
    HELP internal immutable token;
    address internal immutable owner;

    address[] public actors;

    constructor(HELP _token, Vm _vm) {
        token = _token;
        vm = _vm;
        owner = _token.owner();
        actors.push(owner);
    }

    function addActor(address actor) external {
        if (actor != address(0) && actor != owner) {
            actors.push(actor);
        }
    }

    // Owner can mint
    function mint(uint256 amount, address to) external {
        if (to == address(0)) return;
        vm.prank(owner);
        token.mint(to, amount);
    }

    // Owner can burn
    function burn(uint256 amount, address from) external {
        if (from == address(0)) return;
        vm.prank(owner);
        uint256 bal = token.balanceOf(from);
        if (bal < amount) return;
        token.burn(from, amount);
    }

    // Transfer
    function transfer(uint256 amount, address to) external {
        if (to == address(0)) return;

        // Pick a pseudo-random actor
        address sender = actors[uint256(keccak256(abi.encodePacked(amount, to, block.timestamp))) // don't use block.timestamp in production
            % actors.length];

        uint256 bal = token.balanceOf(sender);
        if (bal == 0 || bal < amount) return;

        vm.prank(sender);
        token.transfer(to, amount);
    }

    function getActors() external view returns (address[] memory) {
        return actors;
    }
}
