pragma solidity ^0.8.0;

contract MyToken {
    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balanceOf(msg.sender) >= amount, "ERC20: transfer amount exceeds balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        return true;
    }
    
    // Add the constructor function to mint initial tokens to the deployer
    constructor(uint256 initialSupply) {
        _mint(msg.sender, initialSupply);
    }
    
    function _mint(address account, uint256 amount) internal {
        _totalSupply += amount;
        _balances[account] += amount;
    }
}
