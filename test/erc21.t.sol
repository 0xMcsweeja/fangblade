// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/erc21.sol";

contract ERC20AssemblyTest is Test {
    ERC21 private _token;
    uint256 private _initialSupply = 1000;

    function setUp() public {
        _token = new ERC21(_initialSupply);
    }

    function testTotalSupply() public {
        assertEq(_token.totalSupply(), _initialSupply, "Total supply should be equal to initial supply");
    }

    function testBalanceOf() public {
        // After creating the token, all supply should be assigned to the contract creator
        assertEq(_token.balanceOf(address(this)), _initialSupply, "Balance should be equal to initial supply");
    }
}
