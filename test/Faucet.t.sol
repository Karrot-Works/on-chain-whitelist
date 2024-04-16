// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {BaseSetup, MaliciousContract} from "./BaseSetup.t.sol";
import {FaucetEvents} from "../src/FaucetEvents.sol";
import {Faucet} from "../src/Faucet.sol";

contract FaucetTest is Test, BaseSetup, FaucetEvents {
    Faucet faucetContract;
    uint256 claimAmount;

    function setUp() public override {
        BaseSetup.setUp();

        // deploy the faucet contract
        faucetContract = new Faucet(
            address(earlyAccessNFTAddress),
            0.1 ether,
            60 // 1 minute cooldown
        );
        claimAmount = faucetContract.claimAmount();

        faucetContract.fundFaucet{value: 100 ether}();

        uint256 balance = faucetContract.balance();
        assertEq(balance, 100 ether);
    }

    // test claim
    function test_ClaimShouldPass() public {
        // mint whitelist nft to user1
        earlyAccessNFTContract.mintTo(user1);

        uint256 balanceBefore = address(user1).balance;
        assertEq(balanceBefore, 0);

        bool isSuccess = faucetContract.claim(payable(user1));
        assertEq(isSuccess, true);

        uint256 balanceAfter = address(user1).balance;
        assertEq(balanceAfter, balanceBefore + claimAmount);
    }

    // test should revert if claimed before cool down
    function test_ExpectRevertClaimTooSoon() public {
        // mint whitelist nft to user1
        earlyAccessNFTContract.mintTo(user1);

        faucetContract.claim(payable(user1));
        vm.expectRevert("Faucet: Claim too soon.");
        faucetContract.claim(payable(user1));
    }

    // test should revert if account is not whitelisted
    function test_ExpectRevertClaimAccountNotWhitelisted() public {
        // no mint directly claim
        vm.expectRevert("WhitelistNFT: Account is not whitelisted");
        faucetContract.claim(payable(user1));
    }

    // test should pass when claim amount is set by owner
    function test_SetAmountShouldPass() public {
        faucetContract.setAmount(2);
        uint256 amount = faucetContract.claimAmount();
        assertEq(amount, 2);
    }

    // test should revert if claim amount is set by non owner
    function test_ExpectRevertSetAmount() public {
        vm.startPrank(user1);
        vm.expectRevert();
        faucetContract.setAmount(2);
        vm.stopPrank();
    }

    // test should pass when cool down duration is set by owner
    function test_SetCoolDownDurationShouldPass() public {
        faucetContract.setDuration(2);
        uint256 coolDownDuration = faucetContract.cooldownDuration();
        assertEq(coolDownDuration, 2);
    }

    // test should revert if cool down duration is set by non owner
    function test_ExpectRevertSetCoolDownDuration() public {
        vm.startPrank(user1);
        vm.expectRevert();
        faucetContract.setDuration(2);
        vm.stopPrank();
    }

    // test should pass when faucet is funded
    function test_FundFaucetShouldPass() public {
        uint256 balance = faucetContract.fundFaucet{value: 100 ether}();
        assertEq(balance, 200 ether);
    }

    // test should revert if user claims twice before cool down
    function test_ClaimTwiceBeforeCoolDownShouldRevert() public {
        // mint whitelist nft to user1
        earlyAccessNFTContract.mintTo(user1);

        faucetContract.claim(payable(user1));

        // claim again
        vm.expectRevert("Faucet: Claim too soon.");
        faucetContract.claim(payable(user1));
    }

    // test should pass if user claims second time after cool down
    function test_ClaimTwiceAfterCoolDownShouldPass() public {
        // mint whitelist nft to user1
        earlyAccessNFTContract.mintTo(user1);

        faucetContract.claim(payable(user1));

        // skip blocktime by 60 seconds
        skip(60);

        // claim again
        bool isSuccess = faucetContract.claim(payable(user1));
        assertEq(isSuccess, true);
    }

    // -------- events tests --------

    // test funded event
    function test_FundedEvent() public {
        vm.expectEmit(true, true, false, false);
        emit Funded(address(this), 0.05 ether, block.timestamp);
        faucetContract.fundFaucet{value: 0.05 ether}();
    }

    // test claim event
    function test_ClaimEvent() public {
        // mint whitelist nft to user1

        earlyAccessNFTContract.mintTo(user1);

        vm.expectEmit(true, true, true, false);
        emit Claim(user1, claimAmount, block.timestamp);
        faucetContract.claim(payable(user1));
    }

    // test amount changed event
    function test_AmountChangedEvent() public {
        vm.expectEmit(true, true, true, false);
        emit AmountChanged(address(this), 2, block.timestamp);
        faucetContract.setAmount(2);
    }

    // test duration changed event
    function test_DurationChangedEvent() public {
        vm.expectEmit(true, true, true, false);
        emit DurationChanged(address(this), 2, block.timestamp);
        faucetContract.setDuration(2);
    }

    // -------- reentrancy attack tests --------
    function test_ShouldRevertReentrancyAttack() public {
        // Deploy a malicious contract
        MaliciousContract maliciousContract = new MaliciousContract(
            faucetContract
        );

        // Mint whitelist NFT to malicious contract
        earlyAccessNFTContract.mintTo(address(maliciousContract));

        // Expect reversion due to reentrancy attack
        vm.expectRevert();
        maliciousContract.attack();
        assertEq(address(maliciousContract).balance, 0);
    }
}
