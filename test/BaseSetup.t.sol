// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WhitelistNFT} from "../src/WhitelistNFT.sol";

contract BaseSetup is Test {
    WhitelistNFT whitelistNFTContract;
    address public user1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public user2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    address public whitelistNFTAddress;

    function setUp() public virtual {
        whitelistNFTContract = new WhitelistNFT("WhitelistNFT", "KARROT");
        uint256 balance = whitelistNFTContract.balanceOf(user1);
        whitelistNFTAddress = address(whitelistNFTContract);
        assertEq(balance, 0);
    }
}