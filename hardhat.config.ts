import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";

require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.23",
  },
  etherscan: {
    apiKey: "1EPV8V31JFWHQSIZZSH6UTZWX9SPW5D5UD",
    customChains: [
      {
        network: "alpine-marigold",
        chainId: 98212,
        URL: "https://rpc-alpine-health-rswk3oj77b.t.conduit.xyz/KtrLRd57AguVNvD77Yq8R7a5quCQRWcWb",
        urls: {
          apiURL: "https://explorer-alpine-health-rswk3oj77b.t.conduit.xyz/api",
          browserURL:
            "https://explorer-alpine-health-rswk3oj77b.t.conduit.xyz/",
        },
      },
      {
        network: "base-sepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org",
        },
      },
    ],
  },
  sourcify: {
    enabled: true,
  },
  networks: {
    "alpine-marigold": {
      url: "https://rpc-alpine-health-rswk3oj77b.t.conduit.xyz/KtrLRd57AguVNvD77Yq8R7a5quCQRWcWb",
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    "base-mainnet": {
      url: "https://mainnet.base.org",
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    // for testnet
    "base-sepolia": {
      url: "https://sepolia.base.org",
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    // for local dev environment
    "base-local": {
      url: "http://localhost:8545",
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
  },
  defaultNetwork: "hardhat",
} as any;

export default config;
