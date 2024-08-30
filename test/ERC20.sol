// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(string memory tokenName, string memory tokenSymbol, address to) ERC20(tokenName, tokenSymbol) {
        _mint(to, type(uint256).max);
    }

    // Override the decimals function to return 6
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
