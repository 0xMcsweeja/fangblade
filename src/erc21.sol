/*
Project: ERC20 Assembly

This project aims to implement an ERC20 token using Solidity assembly for efficiency. 
The ERC21 token has the same interfaces as ERC20 but implemented with assembly code where possible. 
This project serves as a learning tool to understand low-level Ethereum Virtual Machine (EVM) operations and their gas efficiency.

Storage Layout:
-------------------
|   Slot   |  Description  |
|----------|---------------|
|   0x00   |   Balances    |
|   0x01   | Total Supply  |
-------------------
*/
pragma solidity ^0.8.0;

contract ERC21 {
    uint256 private constant _BALANCES_POSITION = 0x02;
    uint256 private _totalSupply;

    /*
    Assembly logic:
    1. Store the initial supply in the storage slot 1.
    2. Get the address of the contract creator and store it in memory.
    3. Compute the storage slot where the balance of the creator should be stored by hashing the address with the slot number for balances mapping.
    4. Store the initial supply at the computed slot.
    */
    constructor(uint256 initialSupply) {
        assembly {
            sstore(0x01, initialSupply) // Store the initial supply in the total supply storage slot.
            let callerAddress := caller() // Retrieve the address of the contract creator.
            mstore(0x0, callerAddress) // Store the address in memory.
            mstore(0x20, _BALANCES_POSITION) // Store the storage slot number for balances mapping in memory.
            let slot := keccak256(0x0, 0x40) // Compute the slot for the balance of the contract creator.
            sstore(slot, initialSupply) // Store the initial supply at the computed slot.
        }
    }

    /*
    Assembly logic:
    1. Load the value from the total supply storage slot.
    2. Return the loaded value.
    */
    function totalSupply() public view returns (uint256) {
        uint256 ts;
        assembly {
            ts := sload(0x01) // Load the total supply from storage.
        }
        return ts; // Return the total supply.
    }

    function balanceOf(address account) public view returns (uint256) {
        uint256 accountBalance;
        assembly {
            mstore(0x00, account)
            mstore(0x20, _BALANCES_POSITION)
            let slot := keccak256(0x00, 0x40) // payload from 0x00 with size 0x40 (64 bytes)
            accountBalance := sload(slot)
        }
        return accountBalance;
    }

    /*
    Assembly logic:
    1. Calculate the storage slots for the balances of the sender and the recipient.
    2. Load the sender's balance and check it is sufficient for the transfer.
    3. If so, subtract the amount from the sender's balance and add it to the recipient's balance.
    4. If not, revert the transaction.
    */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        assembly {
            let sender := caller()

            let senderSlot := keccak256(add(sender, _BALANCES_POSITION), 0x40)
            let senderBalance := sload(senderSlot)

            if lt(senderBalance, amount) {
                revert(0, 0)
            }

            let newSenderBalance := sub(senderBalance, amount)
            sstore(senderSlot, newSenderBalance)

            let recipientSlot := keccak256(add(recipient, _BALANCES_POSITION), 0x40)
            let recipientBalance := sload(recipientSlot)

            let newRecipientBalance := add(recipientBalance, amount)
            sstore(recipientSlot, newRecipientBalance)

            mstore(0, 1) // Return true
            return(0, 0x20)
        }
    }

}
