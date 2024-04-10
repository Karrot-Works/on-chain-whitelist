// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EarlyAccessNFT} from "../src/EarlyAccessNFT.sol";

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