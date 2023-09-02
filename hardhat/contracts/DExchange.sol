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

    // The user should be able to remove liquidity as well
    // removing liquidity requires the burning of lpETHTOKEN tokens.
    // The function returns the amount of ETH and TOKEN to be returned.
    function removeLiquidity(uint256 amountLpTokens) public returns (uint256, uint256) {
        require (amountLpTokens > 0, "Amount of LPTokens returning must be positive.");
        require (amountLpTokens <= balanceOf(msg.sender), "Not enough LPTokens to return.");

        uint256 ethReserveBalance = address(this).balance;
        uint256 lpTokensTotalSupply= totalSupply();

        // compute amount of ETH and TKN to be returned to the user based on amountLpTokens to be burnt
        /*  Example
            Alice wants to return 20 lpETHTOKEN
            She gets: 
                - (20 * 110) / 110 = 20 ETH
            and - (20 * 110) / 110 = 20 TKN
            At the end, Alice owns 80 [lpETHTKN] / 90 [totalSupply] =  88% of the pool
            Burnt lpETHTKN do not count in supply.
         */
        uint256 ethToReturn = (amountLpTokens * ethReserveBalance) / lpTokensTotalSupply;
        uint256 tknToReturn = (amountLpTokens * getReserve())/ lpTokensTotalSupply;

        // burn the lp tokens
        _burn(msg.sender, amountLpTokens);
        // transfer ETH to the user
        payable(msg.sender).transfer(ethToReturn);
        // transfer TKN to the user
        ERC20(tokenAddress).transfer(msg.sender, tknToReturn);

        return (ethToReturn, tknToReturn);
    }

    // Users must be able to use the pool to swap ETH<>TKN.
    // The following is a helper function to compute the amount of token the user can get.
    // Computation is based on xy = k = (x+dx)(y-dy) --> dy = (y*dx)/(x+dx)
    function getOutputAmountFromSwap (
        uint256 inputAmount,    // dx
        uint256 inputReserve,   // x
        uint256 outputReserve   // y
    ) public pure returns (uint256) {
        require (inputReserve > 0 && outputReserve > 0, "BAD_INPUT_OUTPUT_RESERVE");

        uint256 inputAmountWithFee = inputAmount * 997/10; // 3% fee of input token
        uint256 numerator = outputReserve * inputAmountWithFee;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }

}