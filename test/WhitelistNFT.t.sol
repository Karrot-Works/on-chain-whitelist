// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WhitelistNFT} from "../src/WhitelistNFT.sol";

contract WhitelistNFTTest is Test {
    uint256 public balance;
    WhitelistNFT earlyAccessNFT;
    address public recipient1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public recipient2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    function setUp() public {
        earlyAccessNFT = new WhitelistNFT("WhitelistNFT", "KARROT");
        balance = earlyAccessNFT.balanceOf(
            recipient1
        );
        assertEq(balance, 0);
    }

    function test_MintToShouldPass() public {
        uint256 tokenId = earlyAccessNFT.mintTo(
            recipient1
        );
        balance = earlyAccessNFT.balanceOf(
            recipient1
        );
        assertEq(balance, 1);
        assertEq(tokenId, 1);
        assertEq(
            earlyAccessNFT.ownerOf(tokenId),
            recipient1
        );

        // token uri
        string memory tokenURI = earlyAccessNFT.tokenURI(tokenId);
        assertEq(tokenURI, "1");
    }

    function test_ExpectRevertTransferSoulBoundNFT() public {
        // mint to recipient1
        uint256 tokenId = earlyAccessNFT.mintTo(
            recipient1
        );
        balance = earlyAccessNFT.balanceOf(
            recipient1
        );

        assertEq(balance, 1);
        assertEq(tokenId, 1);
        assertEq(
            earlyAccessNFT.ownerOf(tokenId),
            recipient1
        );

        // transfer to another address
        vm.expectRevert("Soulbound: Transfer failed");
        earlyAccessNFT.transferFrom(
            recipient1,
            recipient2,
            tokenId
        );

        // mint NFT to recipient2
        earlyAccessNFT.mintTo(
            recipient2
        );
        balance = earlyAccessNFT.balanceOf(
            recipient2
        );

        assertEq(balance, 1);
    }

    function test_ExpectRevertMintToZeroAddress() public {
        vm.expectRevert("ZERO_ADDRESS");
        earlyAccessNFT.mintTo(
            address(0)
        );
    }
}
