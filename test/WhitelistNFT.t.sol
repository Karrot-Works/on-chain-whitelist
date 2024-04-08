// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WhitelistNFT} from "../src/WhitelistNFT.sol";

contract WhitelistNFTTest is Test {
    uint256 public balance;
    WhitelistNFT earlyAccessNFT;

    function setUp() public {
        earlyAccessNFT = new WhitelistNFT("WhitelistNFT", "KARROT");
        balance = earlyAccessNFT.balanceOf(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        assertEq(balance, 0);
    }

    function testMintToShouldPass() public {
        uint256 tokenId = earlyAccessNFT.mintTo(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        balance = earlyAccessNFT.balanceOf(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        assertEq(balance, 1);
        assertEq(tokenId, 1);
    }

    // TODO: Add more tests
}
