import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-foundry";
import '@openzeppelin/hardhat-upgrades';

import 'dotenv/config'

const privateKey = process.env.PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      evmVersion: "cancun",
    }
  },
  networks: {
    hardhat: {
    },
    "kakarot-sepolia": {
      url: "https://sepolia-rpc.kakarot.org",
      accounts: [privateKey!]
    },
    "anvil": {
      url: "http://127.0.0.1:8545",
      accounts: [privateKey!]
    }
  }
};

export default config;
