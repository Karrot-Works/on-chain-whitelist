import { config } from "dotenv";
import { Wallet, JsonRpcProvider, Contract, parseEther } from "ethers";

import EarlyAccessNFTArtifact from "../out/EarlyAccessNFT.sol/EarlyAccessNFT.json";
import FaucetArtifact from "../out/Faucet.sol/Faucet.json";
import { ContractFactory } from "ethers";
import { writeFileSync } from "fs";

config();

const main = async () => {
  if (!process.env.SEPOLIA_RPC_URL) {
    console.error("SEPOLIA_RPC_URL is not set");
    process.exit(1);
  }

  if (!process.env.PRIVATE_KEY) {
    console.error("PRIVATE_KEY is not set");
    process.exit(1);
  }

  const RPC_URL = process.env.SEPOLIA_RPC_URL;
  const PRIVATE_KEY = process.env.PRIVATE_KEY;

  const rpcProvider = new JsonRpcProvider(RPC_URL);
  const sender = new Wallet(PRIVATE_KEY, rpcProvider);

  console.log("deploy EarlyAccessNFT contract ...");

  const nftCollectioName = "EarlyAccessNFTTest";
  const nftTicker = "TEANFT";

  const EarlyAccessNFT = new ContractFactory(
    EarlyAccessNFTArtifact.abi,
    EarlyAccessNFTArtifact.bytecode,
    sender,
  );
  const response = await EarlyAccessNFT.deploy(nftCollectioName, nftTicker);
  await response.waitForDeployment();

  const earlyAccessNFTAddress = await response.getAddress();
  console.log("✅ EarlyAccessNFT deployed to:", earlyAccessNFTAddress);

  console.log("deploy Faucet contract ...");

  const Faucet = new ContractFactory(
    FaucetArtifact.abi,
    FaucetArtifact.bytecode,
    sender,
  );
  // in wei, 0.001 Eth
  const claimAmount = 1000000000000000;
  // in seconds
  const cooldownDuration = 20;

  const faucetResponse = await Faucet.deploy(
    earlyAccessNFTAddress,
    claimAmount,
    cooldownDuration,
  );
  await faucetResponse.waitForDeployment();

  const faucetAddress = await faucetResponse.getAddress();
  console.log("✅ Faucet deployed to:", faucetAddress);

  console.log("writing deployments to file ...");

  writeFileSync(
    "./data/deployments.json",
    JSON.stringify({
      earlyAccessNFT: earlyAccessNFTAddress,
      faucet: faucetAddress,
    }),
  );

  console.log("✅ deployments written to file: data/deployments.json");
};

main();
