// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/erc20_assembly.sol";

contract ERC20AssemblyTest is Test {
    ERC21 private _token;
    uint256 private _initialSupply = 1000;
    address private _otherAccount = address(0x02);
    address private _thirdAccount = address(0x03);  // New account for testing transferFrom

    function setUp() public {
        _token = new ERC21(_initialSupply);
    }

    // ... other test functions remain the same ...

    function testTransferFrom() public {
        uint256 allowanceAmount = 200;
        uint256 transferAmount = 100;
        _token.mint(_otherAccount, 1000);
        // Approve allowance for other account
        _token.approve(_otherAccount, allowanceAmount);
        vm.startPrank(_otherAccount);
        _token.increaseAllowance(address(this), 1000);
        vm.stopPrank();
        // Transfer from this account (token owner) to third account using other account's allowance
        // Note: we need to act as the _otherAccount for the transferFrom call.
        bool success = _token.transferFrom(_otherAccount, _thirdAccount, 100);
        
        // Check the transfer was successful
        assert(success);
        
        // Verify the balances and allowance have been updated correctly
        assertEq(_token.balanceOf(_otherAccount), _initialSupply - transferAmount, "Token owner balance not correctly updated after transferFrom");
        assertEq(_token.balanceOf(_thirdAccount), transferAmount, "Recipient balance not correctly updated after transferFrom");
        assertEq(_token.allowance(address(this), _otherAccount), allowanceAmount - transferAmount, "Spender allowance not correctly updated after transferFrom");
    }
}
