import { config } from "dotenv";
import { Wallet, JsonRpcProvider } from "ethers";

import { writeFileSync } from "fs";
import hardhat from "hardhat";

const { ethers, upgrades } = hardhat;

config();

const main = async () => {

  console.log("deploy EarlyAccessNFT contract ...");

  const nftCollectioName = "EarlyAccessNFTTest";
  const nftTicker = "TEANFT";

  const EarlyAccessNFT = await ethers.getContractFactory("EarlyAccessNFT");
  const response = await EarlyAccessNFT.deploy(nftCollectioName, nftTicker);
  await response.waitForDeployment();

  const earlyAccessNFTAddress = await response.getAddress();
  console.log("✅ EarlyAccessNFT deployed to:", earlyAccessNFTAddress);

  console.log("deploy Faucet contract ...");

  const Faucet = await ethers.getContractFactory("Faucet");

  // in wei, 0.001 Eth
  const claimAmount = 1000000000000000;
  // in seconds
  const cooldownDuration = 20;

  try {
    const faucetContract = await upgrades.deployProxy(
      Faucet,
      [earlyAccessNFTAddress, claimAmount, cooldownDuration],
      { kind: "uups" },
    );

    console.log("waiting for faucet contract to deploy ...");

    const tx = await faucetContract.waitForDeployment();

    const faucetAddress = await faucetContract.getAddress();
    console.log("✅ Faucet deployed to:", faucetAddress);

    console.log("writing deployments to file ...");

    writeFileSync(
      "./data/deployments.json",
      JSON.stringify({
        earlyAccessNFT: earlyAccessNFTAddress,
        faucetProxyAddress: faucetAddress,
      }),
    );
  } catch (e) {
    console.log(e);
  }

  console.log("✅ deployments written to file: data/deployments.json");
};

main();
