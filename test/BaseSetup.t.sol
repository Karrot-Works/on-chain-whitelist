// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EarlyAccessNFT} from "../src/EarlyAccessNFT.sol";
import {Faucet} from "../src/Faucet.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract BaseSetup is Test {
    EarlyAccessNFT earlyAccessNFTContract;
    address public user1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public user2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    address public earlyAccessNFTAddress;

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
        faucet.claim(payable(address(this)));
    }

    // Function to receive Ether
    receive() external payable {
        // Perform reentrancy attack by calling the claim function again
        faucet.claim(payable(address(this)));
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        // Perform reentrancy attack by calling the claim function again
        faucet.claim(payable(address(this)));
    }
}
