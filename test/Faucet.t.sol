// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Faucet} from "../src/Faucet.sol";
import {BaseSetup} from "./BaseSetup.t.sol";

contract FaucetTest is Test, BaseSetup {
    Faucet faucetContract;
    uint256 claimAmount;

    function setUp() public override{
        BaseSetup.setUp();

        // deploy the faucet contract
        faucetContract = new Faucet(address(whitelistNFTAddress), 0.1 ether, 1);
        claimAmount = faucetContract.claimAmount();

        faucetContract.fundFaucet{value: 100 ether}();

        uint256 balance = faucetContract.balance();
        assertEq(balance, 100 ether);
    }

    // test claim
    function test_ClaimShouldPass() public {
        // mint whitelist nft to user1
        whitelistNFTContract.mintTo(user1);

        uint256 balanceBefore = address(user1).balance;
        assertEq(balanceBefore, 0);

        bool isSuccess = faucetContract.claim(payable(user1));
        assertEq(isSuccess, true);

        uint256 balanceAfter = address(user1).balance;
        assertEq(balanceAfter, balanceBefore + claimAmount);
    }

    // test claim too soon
    function test_ExpectRevertClaimTooSoon() public {
        // mint whitelist nft to user1
        whitelistNFTContract.mintTo(user1);

        faucetContract.claim(payable(user1));
        vm.expectRevert("Faucet: Claim too soon.");
        faucetContract.claim(payable(user1));
    }

    // test claim not whitelisted
    function test_ExpectRevertClaimAccountNotWhitelisted() public {
        // no mint
        vm.expectRevert("WhitelistNFT: Account is not whitelisted");
        faucetContract.claim(payable(user1));
    }

    // test set amount
    function test_SetAmountShouldPass() public {
        faucetContract.setAmount(2);
        uint256 amount = faucetContract.claimAmount();
        assertEq(amount, 2);
    }

    // test set cool down duration
    function test_SetCoolDownDurationShouldPass() public {
        faucetContract.setDuration(2);
        uint256 coolDownDuration = faucetContract.cooldownDuration();
        assertEq(coolDownDuration, 2);
    }

    // test fund faucet
    function test_FundFaucetShouldPass() public {
        uint256 balance = faucetContract.fundFaucet{value: 100 ether}();
        assertEq(balance, 200 ether);
    }

    // test only owner can set amount
    function test_ExpectRevertSetAmount() public {
        vm.startPrank(user1);
        vm.expectRevert();
        faucetContract.setAmount(2);
        vm.stopPrank();
    }

    // test only owner can set cool down duration
    function test_ExpectRevertSetDuration() public {
        vm.startPrank(user1);
        vm.expectRevert();
        faucetContract.setDuration(2);
        vm.stopPrank();
    }

}

