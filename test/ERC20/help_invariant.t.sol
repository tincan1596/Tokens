// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {HELP} from "../../src/ERC20/imports/help.sol";
import {HELPHandler} from "./help_handler.t.sol";

contract HELPInvariants is StdInvariant, Test {
    HELP internal token;
    HELPHandler internal handler;

    function setUp() public {
        token = new HELP(1_000_000 ether); // Deploy HELP token
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

    /// ✅ Invariant 1: Total supply must always equal sum of balances
    function invariant_totalSupplyMatchesBalances() public view {
        uint256 total;
        address[] memory actors = handler.getActors();
        for (uint256 i = 0; i < actors.length; i++) {
            total += token.balanceOf(actors[i]);
        }
        assertEq(token.totalSupply(), total, "Total supply mismatch");
    }

    /// ✅ Invariant 2: No account should ever have a negative balance (implicit in uint256)
    function invariant_noNegativeBalance() public view {
        address[] memory actors = handler.getActors();
        for (uint256 i = 0; i < actors.length; i++) {
            assertGe(token.balanceOf(actors[i]), 0, "Negative balance found");
        }
    }

    /// ✅ Invariant 3: Allowance must never exceed owner's balance
    function invariant_allowanceNotExceedBalance() public view {
        address[] memory actors = handler.getActors();
        for (uint256 i = 0; i < actors.length; i++) {
            for (uint256 j = 0; j < actors.length; j++) {
                uint256 allowance = token.allowance(actors[i], actors[j]);
                uint256 balance = token.balanceOf(actors[i]);
                assertLe(allowance, balance, "Allowance exceeds balance");
            }
        }
    }
}
