// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  // Deploy the TOKEN contract
  const tokenContract = await hre.ethers.deployContract("Token");
  await tokenContract.waitForDeployment();
  console.log("Token deployed to:", tokenContract.target);

  // Deploy the Exchange Contract
  const exchangeContract = await hre.ethers.deployContract("DExchange", [tokenContract.target]);
  await exchangeContract.waitForDeployment();
  console.log("Exchange deployed to:", exchangeContract.target);

  // wait for 30s so Etherscan can catch up contract deployment
  await sleep(30 * 1000);

  // Verify the contracts on Etherscan
  await hre.run("verify:verify", {
    address: exchangeContract.target,
    constructorArguments: [tokenContract.target],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
