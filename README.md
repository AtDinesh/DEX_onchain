# DEX_onchain

This project demonstrates the building of a basic Decentralized EXchange (DEX) with simple Automated Market Maker (AMM) functionalities.
The frontend part of the project may be done in the future. However, this project is first intended to gain experience in building smart contracts.

## Specifications
The Objective of the DEX is to allow swapping tokens (ETH <> TOKEN)
- The DEX charges 0.3% fee on each swap
- Users can add liquidity. As a counterpart, they receive LP Tokens that represents their share of the pool
- Liquidity Providers must be able to burn their LP tokens to receive back ETH and TOKEN.

## Deployment Notes
- Token contract address: 0x940b6EA91f8270D5ab6240A0f674E61a4301c814
- DExchange contract address: 0xa8F108bFff7693DdAFbbbCeefaE89E305DF60D32

[DExchange contract verified on Etherscan](https://sepolia.etherscan.io/address/0xa8F108bFff7693DdAFbbbCeefaE89E305DF60D32#code)