// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// simple ERC20 token
contract Token is ERC20 {
    // Initializing the contract with 1 million tokens
    constructor() ERC20("Token", "TKN") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}