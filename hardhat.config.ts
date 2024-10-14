import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-foundry";
import '@openzeppelin/hardhat-upgrades';
import "@nomicfoundation/hardhat-toolbox";

import 'dotenv/config'

const privateKey = process.env.PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      evmVersion: "cancun",
    },
  },
  networks: {
    hardhat: {
    },
    "kakarot-starknet-sepolia": {
      url: "https://sepolia-rpc.kakarot.org",
      accounts: [privateKey!]
    },
    "anvil": {
      url: "http://127.0.0.1:8545",
      accounts: [privateKey!]
    },
  },
  etherscan: {
    apiKey: {
      "kakarot-sepolia": "testnet/evm/1802203764"
    },
    customChains: [
      {
        network: "kakarot-sepolia",
        chainId: 1802203764,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/1802203764_2/etherscan",
          browserURL: "https://routescan.io"
        }
      }
    ]
  }
};

export default config;
