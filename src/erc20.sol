// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../lib/open-zeppelin/contracts/token/ERC20/ERC20.sol";
import "../lib/open-zeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../lib/open-zeppelin/contracts/security/Pausable.sol";
import "../lib/open-zeppelin/contracts/access/AccessControl.sol";
import "../lib/open-zeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "../lib/open-zeppelin/contracts/utils/math/SafeMath.sol";

contract Mock is ERC20, ERC20Burnable, Pausable, AccessControl, ERC20Permit {
    using SafeMath for uint256;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant KYC_ROLE = keccak256("KYC_ROLE");

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    error InsufficientBalance();
    error InsufficientAllowance();
    error InvalidPermit();
    error PermitExpired();
    error SenderNotKYC(address addr);
    error ReceiverNotKYC(address addr);

    constructor() ERC20("Mock", "MOCK") ERC20Permit("Mock") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(KYC_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        if (!hasRole(KYC_ROLE, to)) revert ReceiverNotKYC(to);
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        if (from != address(0) && !hasRole(KYC_ROLE, from)) revert SenderNotKYC(from); // not minting
        if (to != address(0) && !hasRole(KYC_ROLE, to)) revert ReceiverNotKYC(to); // not burning
        super._beforeTokenTransfer(from, to, amount);
    }
}
