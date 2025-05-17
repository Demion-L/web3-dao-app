import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  paths: {
    sources: "../contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  networks: {
    hardhat: {
      chainId: 1337,
      forking: {
        url: "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID",
        blockNumber: 15000000, // Optional: specify a block number to fork from
      },
      mining: {
        auto: true,
        interval: 1000, // Mining interval in milliseconds
      },
    },
  }
    // localhost: {  
};

export default config;
