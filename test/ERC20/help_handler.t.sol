// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {HELP} from "../../src/ERC20/imports/help.sol";
import {Vm} from "forge-std/Vm.sol";

contract HELPHandler {
    HELP internal immutable token;
    Vm internal immutable vm;
    address internal immutable owner;

    mapping(address => uint256) public actorBalances;
    address[] public actorList;

    constructor(HELP _token, Vm _vm) {
        token = _token;
        vm = _vm;
        owner = _token.owner();

        _addActor(owner);

        for (uint256 i = 0; i < 4; i++) {
            address actor = address(uint160(uint256(keccak256(abi.encodePacked(i, block.number)))));
            _addActor(actor);
            vm.prank(owner);
            token.mint(actor, 10000);
            actorBalances[actor] = 10000;
        }
        actorBalances[owner] = token.balanceOf(owner);
    }

    function manualBound(uint256 value, uint256 min, uint256 max) internal pure returns (uint256) {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    function _addActor(address addr) internal {
        if (actorBalances[addr] == 0) {
            actorList.push(addr);
        }
    }

    function callApproveAndTransferFrom(uint96 amount, uint256 seed_spender, uint256 seed_recipient, uint256 seed_main)
        public
    {
        address spender = actorList[seed_spender % actorList.length];
        address recipient = actorList[seed_recipient % actorList.length];
        address main = actorList[seed_main % actorList.length];

        if (recipient == address(0) || spender == address(0) || main == address(0) || spender == recipient) return;

        amount = uint96(manualBound(amount, 0, token.balanceOf(main)));

        vm.prank(main);
        token.approve(spender, amount);

        vm.prank(spender);
        token.transferFrom(main, recipient, amount);

        actorBalances[main] -= amount;
        actorBalances[recipient] += amount;
    }

    function callTransfer(uint96 amount, uint256 seed_sender, address to) public {
        if (to == address(0) || actorList.length == 0) return;

        address sender = actorList[seed_sender % actorList.length];
        uint256 bal = token.balanceOf(sender);
        if (bal == 0) return;

        amount = uint96(manualBound(amount, 0, bal));

        _addActor(to);

        vm.prank(sender);
        token.transfer(to, amount);

        actorBalances[sender] -= amount;
        actorBalances[to] += amount;
    }

    function callMint(uint96 amount, address to) public {
        if (to == address(0)) return;

        _addActor(to);

        vm.prank(owner);
        token.mint(to, amount);

        actorBalances[to] += amount;
    }

    function callBurn(uint96 amount, uint256 seed_from) public {
        address from = actorList[seed_from % actorList.length];

        uint256 bal = token.balanceOf(from);
        if (bal == 0) return;

        amount = uint96(manualBound(amount, 0, bal));

        vm.prank(owner);
        token.burn(from, amount);

        actorBalances[from] -= amount;
    }

    function totalShadowSupply() public view returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < actorList.length; i++) {
            sum += actorBalances[actorList[i]];
        }
        return sum;
    }

    function getActors() public view returns (address[] memory) {
        return actorList;
    }
}
