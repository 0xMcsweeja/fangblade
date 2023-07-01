// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/erc21.sol";

contract ERC20AssemblyTest is Test {
    ERC21 private _token;
    uint256 private _initialSupply = 1000;
    address private _otherAccount = address(0x02);

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

    function testTransfer() public {
        uint256 transferAmount = 100;

        // Make sure the contract has enough tokens to transfer
        assert(_token.balanceOf(address(this)) >= transferAmount);

        // Execute transfer
        bool success = _token.transfer(_otherAccount, transferAmount);
        
        // Check the transfer was successful
        assert(success);
        
        // Verify the balances have been updated correctly
        assertEq(_token.balanceOf(address(this)), _initialSupply - transferAmount, "Sender balance not correctly updated after transfer");
        assertEq(_token.balanceOf(_otherAccount), transferAmount, "Recipient balance not correctly updated after transfer");
    }
}
