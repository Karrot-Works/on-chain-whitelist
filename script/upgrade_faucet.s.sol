// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Script, console} from "forge-std/Script.sol";
import "forge-std/console.sol";

contract UpgradeFaucet is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory deploymentJson = vm.readFile("data/deployments.json");

        string memory proxyAddress = vm.parseJsonString(deploymentJson, ".faucetProxyAddress");
        
        address proxyAddressParsed = vm.parseAddress(proxyAddress);
        Upgrades.upgradeProxy(proxyAddressParsed, "FaucetV2.sol", "");
    }
}
