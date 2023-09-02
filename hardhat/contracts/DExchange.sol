// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract is ERC20 because it needs to mint and issue LP Tokens
contract DExchange is ERC20 {
    address public tokenAddress;    // Address of the TOKEN contract for transfers

    // constructor needs the address of TOKEN contract 
    constructor(address token) ERC20("ETH/TOKEN LP Token","lpETHTOKEN")
    {
        require (token != address(0), "token address cannot be null address");
        tokenAddress = token;
    }

    // get the balance of TKN in the exchange
    function getReserve() public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    
}