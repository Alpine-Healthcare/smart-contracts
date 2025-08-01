import { ethers } from "hardhat";

async function main() {
  const alpineAccess = await ethers.deployContract("AlpineHealthAccess");

  await alpineAccess.waitForDeployment();

  console.log(
    `AlpineHealthMarketplace deployed to ${await alpineAccess.getAddress()}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
