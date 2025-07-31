// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20 is IERC20 {
    string name = "Conjunction";
    string symbol = "CONJ";
    uint8 decimals = 18;

    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(uint256 initialSupply) {
        balances[msg.sender] = totalSupply;
        totalSupply = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Approve to the zero address");
        allowed[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 ammount) external returns (bool) {
        require(address(0) != to, "Transfer to the zero address");
        require(balances[from] >= ammount, "Insufficient balance");
        require(allowed[from][msg.sender] >= ammount, "allowed exceeded");
        balances[from] -= ammount;
        balances[to] += ammount;
        allowed[from][msg.sender] -= ammount;

        emit Transfer(from, to, ammount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowed[owner][spender];
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
