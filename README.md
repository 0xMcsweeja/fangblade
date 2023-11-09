# ERC20 written in assembly 
This repository contains the source code for an ERC20 token implemented in Solidity with an emphasis on using assembly for efficiency. It serves as a learning tool to understand low-level Ethereum Virtual Machine (EVM) operations and their gas efficiency.

- [x] `balanceOf`
- [x] `transfer`
- [x] `totalSupply`
- [x] `approve`
- [x] `allowance`
- [x] `transferFrom`
- [x] `increaseAllowance`
- [x] `decreaseAllowance`
- [x] `mint`

## Table of Contents

- [ERC20 written in assembly](#erc20-written-in-assembly)
  - [Table of Contents](#table-of-contents)
  - [ERC20 Interface](#erc20-interface)
  - [Understanding EVM and Assembly ](#understanding-evm-and-assembly-)
  - [Storage and Memory Layout ](#storage-and-memory-layout-)
    - [Storage Layout:](#storage-layout)
    - [Memory Layout:](#memory-layout)
## ERC20 Interface

The ERC20 standard defines an interface that every compliant token contract should implement. Here is a brief summary:

| Method/Event                                                                 | Description                                                                                                  |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `name()`                                                                     | (Optional) Returns the name of the token, e.g. "MyToken".                                                    |
| `symbol()`                                                                   | (Optional) Returns the symbol of the token, e.g. "HIX".                                                      |
| `decimals()`                                                                 | (Optional) Returns the number of decimals the token uses.                                                    |
| `totalSupply()`                                                              | Returns the total token supply.                                                                              |
| `balanceOf(address _owner)`                                                  | Returns the account balance of another account with address _owner.                                          |
| `transfer(address _to, uint256 _value)`                                      | Transfers `_value` amount of tokens to address `_to`, and MUST fire the Transfer event.                      |
| `transferFrom(address _from, address _to, uint256 _value)`                   | Transfers `_value` amount of tokens from address `_from` to address `_to`, and MUST fire the Transfer event. |
| `approve(address _spender, uint256 _value)`                                  | Allows `_spender` to withdraw from your account multiple times, up to the `_value` amount.                   |
| `allowance(address _owner, address _spender)`                                | Returns the amount which `_spender` is still allowed to withdraw from `_owner`.                              |
| `Transfer(address indexed _from, address indexed _to, uint256 _value)`       | MUST trigger when tokens are transferred, including zero value transfers.                                    |
| `Approval(address indexed _owner, address indexed _spender, uint256 _value)` | MUST trigger on any successful call to `approve(address _spender, uint256 _value)`.                          |

## Understanding EVM and Assembly <a name="understanding-assembly"></a>

Solidity, the most popular language for writing smart contracts, compiles down to Ethereum Virtual Machine (EVM) bytecode. Understanding the EVM and assembly language can help developers write more efficient contracts and better understand how the EVM executes them.

In this project, we utilize inline assembly, a feature provided by Solidity that lets developers write EVM assembly code directly in Solidity contracts. We use it here to optimize certain ERC21 token functions.
## Storage and Memory Layout <a name="storage-layout"></a>

In Ethereum smart contracts, storage and memory spaces are separate and serve different purposes. Below, we illustrate a generalized layout:

### Storage Layout:

Storage is persistent between function calls and transactions. Each account has a data area called storage, which is persistent between function calls and transactions. Here's an example of what the storage layout might look like:

| Slot | Description             |
| ---- | ----------------------- |
| 0x00 | Contract Owner          |
| 0x01 | Total Supply            |
| 0x02 | Balances Mapping Slot   |
| 0x03 | Allowances Mapping Slot |
| 0x04 | Token Name              |
| 0x05 | Token Symbol            |
| ...  | ...                     |

### Memory Layout:

Memory is temporary and is erased between external function calls. It is cheaper to use and is the appropriate place to hold temporary variables. Here's an example of what the memory layout might look like in a function:

| Slot | Description               |
| ---- | ------------------------- |
| 0x00 | Temporary Variable 1      |
| 0x20 | Temporary Variable 2      |
| 0x40 | Temporary Variable 3      |
| 0x60 | Temporary Return Variable |
| ...  | ...                       |


Here is a reference table for common Ethereum data types:

| Item           | Description                                                           | Size                |
| -------------- | --------------------------------------------------------------------- | ------------------- |
| `uint`         | Unsigned integer                                                      | 32 bytes (256 bits) |
| `address`      | Holds an Ethereum address                                             | 20 bytes            |
| `bool`         | Boolean, can be either true or false                                  | 1 byte              |
| `bytes32`      | Fixed-size byte array                                                 | 32 bytes            |
| `bytes`        | Dynamically-sized byte array                                          | Varies              |
| `mapping`      | Holds key-value pairs                                                 | Varies              |
| `Word`         | EVM's natural unit of data storage and manipulation                   | 32 bytes (256 bits) |
| `Slot`         | The smallest unit of storage that can be directly addressed           | 32 bytes (256 bits) |
| `Storage Slot` | Slot in the blockchain's state storage (for state variables)          | 32 bytes (256 bits) |
| `Memory Slot`  | Slot in the EVM's memory space (for function variables and arguments) | 32 bytes (256 bits) |

Here is a reference table for common sizes in the EVM:

| Item                              | Size in bytes | Size in hexadecimal |
| --------------------------------- | ------------- | ------------------- |
| `uint` (unsigned integer)         | 32 bytes      | 0x20                |
| `address` (Ethereum address)      | 20 bytes      | 0x14                |
| `bytes32` (fixed-size byte array) | 32 bytes      | 0x20                |
| `1` (as a number)                 | 1 byte        | 0x01                |
| `32` (as a number)                | 1 byte        | 0x20                |
| `64` (as a number)                | 1 byte        | 0x40                |

test