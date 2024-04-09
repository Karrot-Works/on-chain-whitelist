// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract WhitelistNFT is ERC721, Ownable, ERC721Burnable {
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

    /**
     * @dev Called internally by _mint, _burn, _transfer and _transferFrom functions
     * we only allow minting and burning of tokens
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        address owner = _ownerOf(tokenId);

        // if to and owner are non zero addresses, then it is a transfer
        // we do not allow transfers
        require(
            !(to != address(0) && owner != address(0)),
            "Soulbound: Transfer not allowed"
        );

        return super._update(to, tokenId, auth);
    }
}
