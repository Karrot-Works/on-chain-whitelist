// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EarlyAccessNFT} from "../src/EarlyAccessNFT.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Faucet} from "../src/Faucet.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract BaseSetup is Test {
    EarlyAccessNFT earlyAccessNFTContract;
    ERC20 usdc;
    ERC20 usdt;

    address public user1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public user2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    address public earlyAccessNFTAddress;
    address public usdcAddress;
    address public usdtAddress;

    function setUp() public virtual {
        earlyAccessNFTContract = new EarlyAccessNFT("EarlyAccessNFT", "KARROT");
        earlyAccessNFTAddress = address(earlyAccessNFTContract);
    }
}

// Contract to simulate a reentrancy attack
contract MaliciousContract is ERC721Holder {
    Faucet private faucet;

    constructor(Faucet _faucet) {
        faucet = _faucet;
    }

    // Function to perform reentrancy attack
    function attack() external {
        // Call the claim function of the UpgradeableFaucet contract
        faucet.claim(payable(address(this)), false);
    }

    // Function to receive Ether
    receive() external payable {
        // Perform reentrancy attack by calling the claim function again
        faucet.claim(payable(address(this)), false);
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        // Perform reentrancy attack by calling the claim function again
        faucet.claim(payable(address(this)), false);
    }
}

// erc20 contract
contract Token is ERC20 {
    constructor(string memory tokenName, string memory tokenSymbol, address to) ERC20(tokenName, tokenSymbol) {
        _mint(to, 1000);
    }

    // Override the decimals function to return 6
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
