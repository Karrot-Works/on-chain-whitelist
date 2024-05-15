import { config } from "dotenv";
import hardhat from "hardhat";
import deployments from "../data/deployments.json";
const { ethers, upgrades } = hardhat;

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

    console.log("upgrading Faucet contract ...");

    const Faucet = await ethers.getContractFactory("Faucet");

    console.log("Faucet proxy address:", deployments.faucetProxyAddress);

    const upgradedContract = await upgrades.upgradeProxy(deployments.faucetProxyAddress, Faucet);

    const address = await upgradedContract.getAddress();
    console.log("✅ Faucet contract upgraded at proxy address", address);
}

main()
