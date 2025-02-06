import { ethers } from 'hardhat';

async function main() {
  const alpine = await ethers.deployContract('AlpineHealthcare');

  await alpine.waitForDeployment();

  console.log('Alpine Healthcare Contract Deployed at ' + alpine.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});