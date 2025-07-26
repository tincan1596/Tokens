// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HELP is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("HELP", "HLP") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 1e18); // mint initial supply of tokens
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount * 1e18); // mint additional tokens ot a specific address
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount * 1e18); // burn tokens from a specific address
    }
}
