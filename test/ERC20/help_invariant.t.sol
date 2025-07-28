// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {HELP} from "../../src/ERC20/imports/help.sol";
import {HelpTokenHandler} from "./help_handler.t.sol";

contract HELPInvariants is Test {
    HELP internal token;
    HelpTokenHandler internal handler;

    function setUp() public {
        // Deploy HELP token with initial supply
        token = new HELP(1_000_000 ether);

        // Deploy handler (auto-creates random actors + mints tokens)
        handler = new HelpTokenHandler(token, vm);

        // Tell Foundry to use the handler for invariants
        targetContract(address(handler));
    }

    // Total supply should always be equal to sum of balances
    function invariant_TotalSupplyMatchesBalances() public view {
        uint256 total;
        address[] memory actors = handler.getActors();

        for (uint256 i = 0; i < actors.length; i++) {
            total += token.balanceOf(actors[i]);
        }

        assertEq(total, token.totalSupply(), "Total supply mismatch");
    }

    // No actor should ever have more tokens than totalSupply
    function invariant_NoActorExceedsSupply() public view {
        address[] memory actors = handler.getActors();
        for (uint256 i = 0; i < actors.length; i++) {
            assertLe(token.balanceOf(actors[i]), token.totalSupply(), "Actor balance > total supply");
        }
    }

    // Allowances should never exceed totalSupply
    function invariant_AllowancesNeverExceedSupply() public view {
        address[] memory actors = handler.getActors();
        for (uint256 i = 0; i < actors.length; i++) {
            for (uint256 j = 0; j < actors.length; j++) {
                uint256 allowance = token.allowance(actors[i], actors[j]);
                assertLe(allowance, token.totalSupply(), "Allowance > total supply");
            }
        }
    }
}
