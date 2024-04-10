// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @dev Interface of the on-chain kakarot faucet
 */
interface IFaucet {
    /**
     * @dev Returns the current balance of the faucet.
     */
    function balance() external view returns (uint256);

    /**
     * @dev Returns the block time at which eth was claimed by `account`.
     */
    function lastClaimed(address account) external view returns (uint256);

    /**
     * @dev Moves tokens from the faucet account to `to`.
     *
     * It makes a call to the `balanceOf` method of the Whitelist NFT collection, to make sure that address `to` holds a whitelist NFT.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function claim(address payable to) external returns (bool);

    /**
     *  @dev allows anyone to deposit to the faucet
     */
    function fundFaucet() external payable returns (uint256);

    /**
     * @dev changes the current being funded per address to `amount`.
     *
     * This function should only be callable by the contract owner
     */
    function setAmount(uint256 amount) external returns (bool);

    /**
     * @dev changes the current time interval between two claims to `duration`,
     * which is measured in the number of blocks
     *
     * This function should only be callable by the contract owner
     */
    function setDuration(uint256 duration) external returns (bool);
}
