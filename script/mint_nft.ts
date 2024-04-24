import { config } from "dotenv";
import { Wallet, JsonRpcProvider, Contract, parseEther } from "ethers";

import EarlyAccessNFTArtifact from "../out/EarlyAccessNFT.sol/EarlyAccessNFT.json";
import deployments from "../data/deployments.json";

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

  const receiver = Wallet.createRandom();
  console.log(`Receiver address: ${receiver.address}`);

  const nftContract = new Contract(
    deployments.earlyAccessNFT,
    EarlyAccessNFTArtifact.abi,
    sender,
  );

  console.log(`Starting to mint whitelisted NFT to receiver...`);

  const earlyAccessNFTResponse = await nftContract.mintTo(receiver.address);
  await earlyAccessNFTResponse.wait();

  console.log("mint successful ✅, txn hash:", earlyAccessNFTResponse.hash);
};

main();
