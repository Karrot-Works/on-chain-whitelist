// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract WhitelistNFT is ERC721, Ownable {
    uint256 public currentTokenId;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Ownable(msg.sender) {}

    function mintTo(
        address recipient
    ) public payable onlyOwner returns (uint256) {
        // check if recipient is not zero address
        require(recipient != address(0), "ZERO_ADDRESS");

        // check if recipient already owns an NFT
        require(balanceOf(recipient) == 0, "ALREADY INVITED");

        uint256 newItemId = ++currentTokenId;
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {
        return Strings.toString(id);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");
        return super.balanceOf(owner);
    }


    //@dev: _update is a function that is called by the internal transfer functions
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        address owner = _ownerOf(tokenId);

        // check if owner is zero address and to is not zero address
        // this is to prevent transfer of soulbound NFT
        // owner of NFT before minting is zero address
        require(owner == address(0) && to != address(0), "Soulbound: Transfer failed");

        return super._update(to, tokenId, auth);
    }
}
