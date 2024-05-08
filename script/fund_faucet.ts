import { config } from "dotenv";
import { Wallet, JsonRpcProvider, Contract, parseEther } from "ethers";

import FaucetArtifact from "../out/Faucet.sol/Faucet.json";
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


  console.log('faucet proxy Address: ', deployments.FaucetProxy);

  const faucetContract = new Contract(
    deployments.FaucetProxy,
    FaucetArtifact.abi,
    sender,
  );

  console.log("Funding faucet with 0.015 Eth ...");
  console.log("balance before: ", await faucetContract.balance());

  const fundingResponse = await faucetContract.fundFaucet({
    value: parseEther("0.015"),
  });
  await fundingResponse.wait();
  console.log("funding successful ✅, txn hash:", fundingResponse.hash);

  console.log("balance after: ", await faucetContract.balance());
};

main();
