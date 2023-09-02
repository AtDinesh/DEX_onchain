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

    // As the user adds liquidity, he should be given LP tokens.
    // This function computes the amount of LP tokens that should be transfered to the user.
    function addLiquidity(uint256 amount) public payable returns (uint256) {
        uint256 lpTokensToMint;
        uint256 ethReserveBalance = address(this).balance;
        uint256 tokenReserveBalance = getReserve();

        ERC20 token = ERC20(tokenAddress);

        // If the reserve is empty, the user can deposit arbritrary amount of token
        if (tokenReserveBalance == 0) {
            // accept transfer from user to exchange
            token.transferFrom(msg.sender, address(this), amount);

            // Amount of LP tokens to mint is proportional to ETH deposit in the balance
            lpTokensToMint = ethReserveBalance;

            // Mint the LP tokens and send to the user
            _mint(msg.sender, lpTokensToMint);

            return lpTokensToMint;
        }

        // If the reserve is not empty, we should compute differently the amount of tokens to be minted
        // we also should check the corresponding amount of TKN the user should deposit.
        uint256 ethReserveBeforeDeposit = ethReserveBalance - msg.value;
        // following x*y=k rule
        uint256 minTokenAmountRequired = (msg.value * tokenReserveBalance) / ethReserveBeforeDeposit;

        require(amount >= minTokenAmountRequired, "Insufficient amount of TOKEN provided");
        // accept transfer of minTokenAmountRequired from user to exchange
        token.transferFrom(msg.sender, address(this), minTokenAmountRequired);

        // compute how much lptokens should be given to the user
        /*Example
          Alice first deposits 100 ETH and receive 100 lpETHTOKEN
          Bob comes first and deposits 10 ETH, He reseives:
          100 [lpETHTOKEN] * 10 [ETH] / 100 [ETH] = 10 [lpETHTOKEN]
          At the end, Alice owns 100/110 = 90.9% of the liquidity and Bob owns 9.09%.
        */
        lpTokensToMint = (totalSupply() * msg.value)/(ethReserveBeforeDeposit);

        // Mint the LP tokens and send to the user
        _mint(msg.sender, lpTokensToMint);
        return lpTokensToMint;
    }
    
}