// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract EarlyAccessNFT is ERC721, Ownable, ERC721Burnable, ERC721Enumerable {
    uint256 public currentTokenId;
    string public baseURI;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Ownable(msg.sender) {}

    function mintTo(
        address recipient
    ) public onlyOwner returns (uint256) {
        // check if recipient is not zero address
        require(recipient != address(0), "ZERO_ADDRESS");

        // check if recipient already owns an NFT
        require(balanceOf(recipient) == 0, "ALREADY INVITED");

        uint256 newItemId = ++currentTokenId;
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    /**
     * @dev override _baseURI to set the base URI
     * returns the baseURI
     */
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev set the base URI
     */
    function setBaseURI(string memory _baseURI_) public onlyOwner {
        baseURI = _baseURI_;
    }

    // The following functions are overrides required by Solidity for the ERC721 and ERC721Enumerable contracts

    /**
     * @dev Called internally by _mint, _burn, _transfer and _transferFrom functions
     * we only allow minting and burning of tokens
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override (ERC721, ERC721Enumerable) returns (address) {
        address owner = _ownerOf(tokenId);

        // if to and owner are non zero addresses, then it is a transfer
        // we do not allow transfers
        require(
            !(to != address(0) && owner != address(0)),
            "Soulbound: Transfer not allowed"
        );

        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


}
