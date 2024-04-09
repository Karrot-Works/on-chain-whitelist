// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WhitelistNFT} from "../src/WhitelistNFT.sol";

contract WhitelistNFTTest is Test {
    WhitelistNFT earlyAccessNFT;
    address public recipient1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public recipient2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    function setUp() public {
        earlyAccessNFT = new WhitelistNFT("WhitelistNFT", "KARROT");
        uint256 balance = earlyAccessNFT.balanceOf(recipient1);
        assertEq(balance, 0);
    }

    //  -------- mint tests --------

    // test should pass if the NFT is minted to the recipient
    function test_MintToShouldPass() public {
        uint256 tokenId = earlyAccessNFT.mintTo(recipient1);
        uint256 balance = earlyAccessNFT.balanceOf(recipient1);
        assertEq(balance, 1);
        assertEq(tokenId, 1);
        assertEq(earlyAccessNFT.ownerOf(tokenId), recipient1);

        // token uri
        string memory tokenURI = earlyAccessNFT.tokenURI(tokenId);
        assertEq(tokenURI, "1");
    }

    // test should revert if minting to a zero address
    function test_ExpectRevertMintToZeroAddress() public {
        vm.expectRevert("ZERO_ADDRESS");
        earlyAccessNFT.mintTo(address(0));
    }

    //  -------- soulbound tests --------

    // test should revert if the NFT is transferred to another address
    function test_ExpectRevertTransferSoulBoundNFT() public {
        // mint to recipient1
        uint256 tokenId = earlyAccessNFT.mintTo(recipient1);

        // transfer to another address
        vm.expectRevert("Soulbound: Transfer not allowed");
        earlyAccessNFT.transferFrom(recipient1, recipient2, tokenId);
    }

    // test should revert if minting to an address that already has an NFT
    function test_ExpectRevertMintToAlreadyInvited() public {
        // mint to recipient1
        earlyAccessNFT.mintTo(recipient1);
        uint256 balance = earlyAccessNFT.balanceOf(recipient1);

        assertEq(balance, 1);

        // mint to recipient1 again
        vm.expectRevert("ALREADY INVITED");
        earlyAccessNFT.mintTo(recipient1);
    }

    //  -------- burn tests --------

    // test should pass if the NFT holder burns the NFT
    function test_BurnNFTShouldPass() public {
        // mint to recipient1
        uint256 tokenId = earlyAccessNFT.mintTo(recipient1);
        uint256 balance = earlyAccessNFT.balanceOf(recipient1);

        // burn NFT
        vm.startPrank(recipient1); // impersonate recipient1 to burn NFT because only the NFT holder can burn their NFT 
        earlyAccessNFT.burn(tokenId);
        balance = earlyAccessNFT.balanceOf(recipient1);
        assertEq(balance, 0);

        vm.expectRevert(); // token is non existent hence revert
        earlyAccessNFT.ownerOf(tokenId);

    }

    // test should revert if someone other than the NFT holder tries to burn the NFT
    function test_ExpectRevertBurnNFT() public {
        // mint to recipient1
        uint256 tokenId = earlyAccessNFT.mintTo(recipient1);

        // burn NFT
        vm.expectRevert();
        earlyAccessNFT.burn(tokenId); // burn is called by the contract owner (msg.sender)

        // check if the NFT is still owned by recipient1
        assertEq(earlyAccessNFT.ownerOf(tokenId), recipient1);

        // burn NFT by recipient2 (not the NFT holder)
        vm.startPrank(recipient2);
        vm.expectRevert();
        earlyAccessNFT.burn(tokenId);
    }
}
