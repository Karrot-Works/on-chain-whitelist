// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "forge-std/console.sol";
import "../src/EarlyAccessNFT.sol";

contract DeployScript is Script {
    function setUp() public {}

    /**
    @dev The script does the following:
        - deploys EarlyAccessNFT
        - deploys a Faucet, which uses this EarlyAccessNFT

        The contracts will be ownable by the private key denoted by environmen variable `PRIVATE_KEY`
     */
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory nftCollectioName = "EarlyAccessNFTTest";
        string memory nftTicker = "TEANFT";

        EarlyAccessNFT nft = new EarlyAccessNFT(nftCollectioName, nftTicker);

        console.logString("EarlyAccess NFT Address:");
        console.logAddress(address(nft));

        // in wei, 0.001 Eth
        uint256 claimAmount = 1000000000000000;
        // in seconds
        uint256 cooldownDuration = 20;

        address proxyAddress = Upgrades.deployUUPSProxy(
            "Faucet.sol",
            abi.encodeWithSignature(
                "initialize(address,uint256,uint256)",
                address(nft),
                claimAmount,
                cooldownDuration
            )
        );
        address implementationAddress = Upgrades.getImplementationAddress(
            proxyAddress
        );

        console.logString("Proxy Address:");
        console.logAddress(proxyAddress);

        console.logString("Implementation Address:");
        console.logAddress(implementationAddress);

        vm.stopBroadcast();

        vm.writeJson('{"earlyAccessNFT": "", "faucetProxyAddress": "", "faucetImplementationAddress":""}', "./data/deployments.json");
        vm.writeJson(
            vm.toString((address(nft))),
            "./data/deployments.json",
            ".earlyAccessNFT"
        );
        vm.writeJson(vm.toString(proxyAddress), "./data/deployments.json", ".faucetProxyAddress");
        vm.writeJson(
            vm.toString(implementationAddress),
            "./data/deployments.json",
            ".faucetImplementationAddress"
        );
    }
}
