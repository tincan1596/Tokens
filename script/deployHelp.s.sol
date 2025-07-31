// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import {HELP} from "../src/imports/help.sol";

contract DeployHelp is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        uint256 initialSupply = vm.envUint("INITIAL_SUPPLY");

        vm.startBroadcast(deployerKey);

        HELP help = new HELP(initialSupply); // create instance

        console2.log("HELP token deployed at:", address(help));
        vm.stopBroadcast();
    }
}
