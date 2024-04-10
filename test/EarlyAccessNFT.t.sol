// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract EarlyAccessNFTTest is Test, BaseSetup {

    function setUp() public override {
        BaseSetup.setUp();
    }

    //  -------- mint tests --------

    // test should pass if the NFT is minted to the recipient
    function test_MintToShouldPass() public {
        uint256 tokenId = earlyAccessNFTContract.mintTo(user1);
        uint256 balance = earlyAccessNFTContract.balanceOf(user1);
        assertEq(balance, 1);
        assertEq(tokenId, 1);
        assertEq(earlyAccessNFTContract.ownerOf(tokenId), user1);

        // token uri
        string memory tokenURI = earlyAccessNFTContract.tokenURI(tokenId);
        assertEq(tokenURI, "1");
    }

    // test should revert if minting to a zero address
    function test_ExpectRevertMintToZeroAddress() public {
        vm.expectRevert("ZERO_ADDRESS");
        earlyAccessNFTContract.mintTo(address(0));
    }

    // test should if mintTo is called by someone other than the owner
    function test_ExpectRevertMintToNotOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        earlyAccessNFTContract.mintTo(user1);
        vm.stopPrank();
    }

    //  -------- soulbound tests --------

    // test should revert if the NFT is transferred to another address
    function test_ExpectRevertTransferSoulBoundNFT() public {
        // mint to user1
        uint256 tokenId = earlyAccessNFTContract.mintTo(user1);

        // transfer to another address
        vm.expectRevert("Soulbound: Transfer not allowed");
        earlyAccessNFTContract.transferFrom(user1, user2, tokenId);
    }

    // test should revert if minting to an address that already has an NFT
    function test_ExpectRevertMintToAlreadyInvited() public {
        // mint to user1
        earlyAccessNFTContract.mintTo(user1);
        uint256 balance = earlyAccessNFTContract.balanceOf(user1);

        assertEq(balance, 1);

        // mint to user1 again
        vm.expectRevert("ALREADY INVITED");
        earlyAccessNFTContract.mintTo(user1);
    }

    //  -------- burn tests --------

    // test should pass if the NFT holder burns the NFT
    function test_BurnNFTShouldPass() public {
        // mint to user1
        uint256 tokenId = earlyAccessNFTContract.mintTo(user1);
        uint256 balance = earlyAccessNFTContract.balanceOf(user1);

        // burn NFT
        vm.startPrank(user1); // impersonate user1 to burn NFT because only the NFT holder can burn their NFT 
        earlyAccessNFTContract.burn(tokenId);
        balance = earlyAccessNFTContract.balanceOf(user1);
        assertEq(balance, 0);
        vm.stopPrank();

        vm.expectRevert(); // token is non existent hence revert
        earlyAccessNFTContract.ownerOf(tokenId);

    }

    // test should revert if someone other than the NFT holder tries to burn the NFT
    function test_ExpectRevertBurnNFT() public {
        // mint to user1
        uint256 tokenId = earlyAccessNFTContract.mintTo(user1);

        // burn NFT
        vm.expectRevert();
        earlyAccessNFTContract.burn(tokenId); // burn is called by the contract owner (msg.sender)

        // check if the NFT is still owned by user1
        assertEq(earlyAccessNFTContract.ownerOf(tokenId), user1);

        // burn NFT by user2 (not the NFT holder)
        vm.startPrank(user2);
        vm.expectRevert();
        earlyAccessNFTContract.burn(tokenId);
        vm.stopPrank();
    }
}
