// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IFaucet} from "./IFaucet.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Faucet is IFaucet, Ownable {
    address public WhitelistNFTAddress;

    uint256 public claimAmount;
    uint256 public cooldownDuration; // in seconds
    mapping(address => uint256) private lastClaimTimes;

    constructor(
        address whitelistNFTAddress,
        uint256 _claimAmount,
        uint256 _cooldownDuration
    ) Ownable(msg.sender) {
        WhitelistNFTAddress = whitelistNFTAddress;
        claimAmount = _claimAmount;
        cooldownDuration = _cooldownDuration;
    }

    /**
     * @dev Returns the current balance of the faucet.
     */
    function balance() external view override returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns the block time at which eth was claimed by `account`.
     */
    function lastClaimed(
        address account
    ) external view override returns (uint256) {
        return lastClaimTimes[account];
    }

    /**
     * @dev Moves tokens from the faucet account to `to`.
     *
     * It makes a call to the `balanceOf` method of the Whitelist NFT collection, to make sure that address `to` holds a whitelist NFT.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function claim(address payable to) external returns (bool) {
        require(
            IERC721(WhitelistNFTAddress).balanceOf(to) > 0,
            "WhitelistNFT: Account is not whitelisted"
        );
        require(
            block.timestamp >= lastClaimTimes[to] + cooldownDuration,
            "Faucet: Claim too soon."
        );

        (bool isSuccess, ) = to.call{value: claimAmount}("");
        require(isSuccess, "Failed to send Ether");
        lastClaimTimes[to] = block.timestamp;

        return isSuccess;
    }

    /**
     *  @dev allows anyone to deposit to the faucet
     */
    function fundFaucet() external payable override returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev changes the current being funded per address to `amount`.
     *
     * This function should only be callable by the contract owner
     */
    function setAmount(
        uint256 amount
    ) external override onlyOwner returns (bool) {
        claimAmount = amount;
        return true;
    }

    /**
     * @dev changes the current time interval between two claims to `duration`,
     * which is measured in block timestamps
     *
     * This function should only be callable by the contract owner
     */
    function setDuration(
        uint256 duration
    ) external override onlyOwner returns (bool) {
        cooldownDuration = duration;
        return true;
    }
}
