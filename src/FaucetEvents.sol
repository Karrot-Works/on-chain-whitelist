// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FaucetEvents {
    // Event emitted when ether is claimed
    event Claim(address indexed to, uint256 amount, uint256 timestamp);

    // Event emitted when the amount per claim is changed
    event AmountChanged(address indexed sender, uint256 newAmount, uint256 timestamp);

    // Event emitted when the cooldown duration is changed
    event DurationChanged(address indexed sender, uint256 newDuration, uint256 timestamp);

    // Event emitted when the faucet is funded
    event Funded(address indexed sender, uint256 amount, uint256 timestamp);
}