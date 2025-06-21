import { ethers } from "hardhat";

async function main() {
  // Example initialization data - replace with your actual user data
  const initialUsers: any[] = [
    {
      user: "0x07BD6d82E20FEC1fA4B66592B46Cba018932aDfA",
      pdosRootHash: "QmT6ojkhYeFrKfm1ZySaBjXtgAJ9YrjkDSepckTnf1nFqu",
      computeNode: "0xe4d172EE62f88Ba29D051D60620fEBB308B81F4E",
      agentIds: [1, 2, 3, 4],
      agentInfos: [
        {
          ipfsHash: "QmZNwEYuN8niWryjiL5C669jzQhS7FDQLuAvFBtywK1bf3",
          createdAt: Math.floor(Date.now() / 1000), // Current timestamp in seconds
          isActive: true,
          isPublic: true,
        },
        {
          ipfsHash: "QmbnoJCZLiA3WPomGxD9VV1wPhGxLrKEK7vc9KquvqYjor",
          createdAt: Math.floor(Date.now() / 1000), // Current timestamp in seconds
          isActive: true,
          isPublic: true,
        },
        {
          ipfsHash: "QmTMxAXDkK7XTvPrRoUirJiTwSh6napBX1XerHycqZzeSz",
          createdAt: Math.floor(Date.now() / 1000), // Current timestamp in seconds
          isActive: true,
          isPublic: true,
        },
        {
          ipfsHash: "QmbA2eh7uZJKH2e15YSGdVqzUVVgW3ctVsHie5vMHTgMY6",
          createdAt: Math.floor(Date.now() / 1000), // Current timestamp in seconds
          isActive: true,
          isPublic: true,
        },
      ],
    },
  ];

  const alpine = await ethers.deployContract("AlpineHealth", [initialUsers]);

  await alpine.waitForDeployment();

  console.log(`AlpineHealth deployed to ${await alpine.getAddress()}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
