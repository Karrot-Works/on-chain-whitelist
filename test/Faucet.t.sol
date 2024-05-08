// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {BaseSetup, MaliciousContract} from "./BaseSetup.t.sol";
import {FaucetEvents} from "../src/FaucetEvents.sol";
import "../src/Faucet.sol";
import "./FaucetV2.sol";

contract FaucetTest is Test, BaseSetup, FaucetEvents {
    Faucet faucet;
    address implementationAddress;
    address proxyAddress;

    uint256 claimAmount;

    function setUp() public override {
        BaseSetup.setUp();
        address _proxyAddress = Upgrades.deployUUPSProxy(
            "Faucet.sol",
            abi.encodeWithSignature(
                "initialize(address,uint256,uint256)",
                address(earlyAccessNFTAddress),
                0.1 ether,
                60
            )
        );
        implementationAddress = Upgrades.getImplementationAddress(
            _proxyAddress
        );
        proxyAddress = _proxyAddress;
        faucet = Faucet(proxyAddress);

        claimAmount = faucet.claimAmount();

        faucet.fundFaucet{value: 100 ether}();

        uint256 balance = faucet.balance();
        assertEq(balance, 100 ether);
    }

    function test_upgradeFaucet() public {
        // First, assert the original implementation
        address originalImplementation = Upgrades.getImplementationAddress(
            proxyAddress
        );
        assertEq(implementationAddress, originalImplementation);

        // Upgrade the contract
        Upgrades.upgradeProxy(proxyAddress, "FaucetV2.sol", "");

        // Fetch the updated implementation address from the proxy
        address updatedImplementation = Upgrades.getImplementationAddress(
            proxyAddress
        );

        // Assert that the implementation address has changed
        assertNotEq(updatedImplementation, originalImplementation);

        FaucetV2 upgradedFaucet = FaucetV2(proxyAddress);

        uint256 newVariable = upgradedFaucet.newVariable();
        assertEq(newVariable, 0);

        upgradedFaucet.setNewVariable(100);
        newVariable = upgradedFaucet.newVariable();
        assertEq(newVariable, 100);
    }

    // test claim
    function test_ClaimShouldPass() public {
        // mint whitelist nft to user1
        earlyAccessNFTContract.mintTo(user1);

        uint256 balanceBefore = address(user1).balance;
        assertEq(balanceBefore, 0);

        bool isSuccess = faucet.claim(payable(user1));
        assertTrue(isSuccess);

        uint256 balanceAfter = address(user1).balance;
        assertEq(balanceAfter, balanceBefore + claimAmount);
    }

    // test should revert if claimed before cool down
    function test_ExpectRevertClaimTooSoon() public {
        // mint whitelist nft to user1
        earlyAccessNFTContract.mintTo(user1);

        faucet.claim(payable(user1));
        vm.expectRevert("Faucet: Claim too soon.");
        faucet.claim(payable(user1));
    }

    // test should revert if account is not whitelisted
    function test_ExpectRevertClaimAccountNotWhitelisted() public {
        // no mint directly claim
        vm.expectRevert("WhitelistNFT: Account is not whitelisted");
        faucet.claim(payable(user1));
    }

    // test should pass when claim amount is set by owner
    function test_SetAmountShouldPass() public {
        bool isSuccess = faucet.setAmount(2);
        assertTrue(isSuccess);

        uint256 amount = faucet.claimAmount();
        assertEq(amount, 2);
    }

    // test should revert if claim amount is set by non owner
    function test_ExpectRevertSetAmount() public {
        vm.startPrank(user1);
        vm.expectRevert();
        faucet.setAmount(2);
        vm.stopPrank();
    }

    // test should pass when cool down duration is set by owner
    function test_SetCoolDownDurationShouldPass() public {
        bool isSuccess = faucet.setDuration(2);
        assertTrue(isSuccess);

        uint256 coolDownDuration = faucet.cooldownDuration();
        assertEq(coolDownDuration, 2);
    }

    // test should revert if cool down duration is set by non owner
    function test_ExpectRevertSetCoolDownDuration() public {
        vm.startPrank(user1);
        vm.expectRevert();
        faucet.setDuration(2);
        vm.stopPrank();
    }

    // test should pass when new nft address is set by owner
    function test_SetNFTAddressShouldPass() public {
        bool isSuccess = faucet.setNFTAddress(address(0));
        assertTrue(isSuccess);

        address whitelistNFTAddress = faucet.whitelistNFTAddress();
        assertEq(whitelistNFTAddress, address(0));
    }

    // test should revert if nft address is set by non owner
    function test_ExpectRevertSetNFTAddress() public {
        vm.startPrank(user1);
        vm.expectRevert();
        faucet.setNFTAddress(address(0));
        vm.stopPrank();
    }

    // test should pass when faucet is funded
    function test_FundFaucetShouldPass() public {
        uint256 balance = faucet.fundFaucet{value: 100 ether}();
        assertEq(balance, 200 ether);
    }

    // test should revert if user claims twice before cool down
    function test_ClaimTwiceBeforeCoolDownShouldRevert() public {
        // mint whitelist nft to user1
        earlyAccessNFTContract.mintTo(user1);

        faucet.claim(payable(user1));

        // claim again
        vm.expectRevert("Faucet: Claim too soon.");
        faucet.claim(payable(user1));
    }

    // test should pass if user claims second time after cool down
    function test_ClaimTwiceAfterCoolDownShouldPass() public {
        // mint whitelist nft to user1
        earlyAccessNFTContract.mintTo(user1);

        faucet.claim(payable(user1));

        // skip blocktime by 60 seconds
        skip(60);

        // claim again
        bool isSuccess = faucet.claim(payable(user1));
        assertEq(isSuccess, true);
    }

    // -------- events tests --------

    // test funded event
    function test_FundedEvent() public {
        vm.expectEmit(true, true, false, false);
        emit Funded(address(this), 0.05 ether, block.timestamp);
        faucet.fundFaucet{value: 0.05 ether}();
    }

    // test claim event
    function test_ClaimEvent() public {
        // mint whitelist nft to user1

        earlyAccessNFTContract.mintTo(user1);

        vm.expectEmit(true, true, true, false);
        emit Claim(user1, claimAmount, block.timestamp);
        faucet.claim(payable(user1));
    }

    // test amount changed event
    function test_AmountChangedEvent() public {
        vm.expectEmit(true, true, true, false);
        emit AmountChanged(address(this), 2, block.timestamp);
        faucet.setAmount(2);
    }

    // test duration changed event
    function test_DurationChangedEvent() public {
        vm.expectEmit(true, true, true, false);
        emit DurationChanged(address(this), 2, block.timestamp);
        faucet.setDuration(2);
    }

    // test nft changed event
    function test_NFTAddressChangedEvent() public {
        vm.expectEmit(true, true, true, false);
        emit NFTChanged(address(this), address(0), block.timestamp);
        faucet.setNFTAddress(address(0));
    }

    // -------- reentrancy attack tests --------
    function test_ShouldRevertReentrancyAttack() public {
        // Deploy a malicious contract
        MaliciousContract maliciousContract = new MaliciousContract(
            faucet
        );

        // Mint whitelist NFT to malicious contract
        earlyAccessNFTContract.mintTo(address(maliciousContract));

        // Expect reversion due to reentrancy attack
        vm.expectRevert();
        maliciousContract.attack();
        assertEq(address(maliciousContract).balance, 0);
    }
}
