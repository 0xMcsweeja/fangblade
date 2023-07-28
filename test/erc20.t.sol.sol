// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/erc20.sol";

contract Mocktest is Test {
    Mock public token;

    address bob = vm.addr(0x01);
    address alice = vm.addr(0x02);
    address charlie = vm.addr(0x03);

    function setUp() public {
        token = new Mock();
        token.grantRole(keccak256("KYC_ROLE"), bob);
        token.grantRole(keccak256("KYC_ROLE"), charlie);
        token.grantRole(keccak256("KYC_ROLE"), alice);
    }

    function testMetadata() external {
        assertEq(token.name(), "Mock");
        assertEq(token.symbol(), "MOCK");
        assertEq(token.decimals(), 2);
    }

    function testMint() external {
        token.mint(bob, 100);
        assertEq(token.totalSupply(), 100);
        assertEq(token.balanceOf(bob), 100);
    }

    function testBurn() public {
        uint256 mintAmount = 100;
        uint256 burnAmount = 50;
        vm.assume(burnAmount < mintAmount);
        token.mint(alice, mintAmount);
        vm.startPrank(alice);
        token.burn( burnAmount);

        assertEq(token.totalSupply(), mintAmount - burnAmount);
        assertEq(token.balanceOf(alice), mintAmount - burnAmount);
    }

    function testBurnFuzz(uint256 mintAmount, uint256 burnAmount) public {
        vm.assume(burnAmount < mintAmount);
        token.mint(alice, mintAmount);
        vm.startPrank(alice);
        token.burn( burnAmount);

        assertEq(token.totalSupply(), mintAmount - burnAmount);
        assertEq(token.balanceOf(alice), mintAmount - burnAmount);
    }

    function testApproval() external {
        vm.startPrank(alice);
        token.approve(bob, 100);
        assertEq(token.allowance(alice, bob), 100);
    }

    function testAllowance() external {
        vm.startPrank(alice);
        token.increaseAllowance(bob, 100);
        assertEq(token.allowance(alice, bob), 100);
    }

    function testTransfer() external {
        token.mint(alice, 50);
        vm.startPrank(alice);
        token.transfer(bob, 25);
        assertEq(token.balanceOf(bob), 25);

        token.transfer(charlie, 25);
        assertEq(token.balanceOf(charlie), 25);

        assertEq(token.balanceOf(address(this)), 0);
    }

}
