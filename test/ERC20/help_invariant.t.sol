// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {HELP} from "../../src/ERC20/imports/help.sol";
import {HELPHandler} from "./help_handler.t.sol";

contract HELPInvariants is StdInvariant, Test {
    HELP internal token;
    HELPHandler internal handler;

    function setUp() public {
        token = new HELP(1_000_000); // Deploy HELP token
        handler = new HELPHandler(token, vm);

        // Register the handler as the target contract for invariants
        targetContract(address(handler));

        // Add handler functions to fuzz/invariant testing
        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = handler.callApproveAndTransferFrom.selector;
        selectors[1] = handler.callTransfer.selector;
        selectors[2] = handler.callMint.selector;
        selectors[3] = handler.callBurn.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
    }

    // Total supply must always equal sum of balances
    function invariant_totalSupplyMatchesBalances() public view {
        assertEq(token.totalSupply(), handler.totalShadowSupply(), "Total supply mismatch");
    }

    // No balance discrepancy between token and shadow mapping
    function invariant_balancesMatchShadow() public view {
        address[] memory actors = handler.getActors();
        for (uint256 i = 0; i < actors.length; i++) {
            assertEq(token.balanceOf(actors[i]), handler.actorBalances(actors[i]), "Shadow balance mismatch");
        }
    }
}
