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
            // The 'caller' operation gives the address of the sender.
            // Store this address in memory at position 0x0.
            let senderAdr := caller()
            sstore(0x00, senderAdr)

            // The position of the _balances mapping is the value of the constant _BALANCES_POSITION.
            // Store this position in memory at position 0x20.
            sstore(0x20, _BALANCES_POSITION)
            // Hash the sender's address and the _balances position together to get the storage slot for the sender's balance.
            // Store the result in a variable named 'senderSlot'.
            let slot := keccak256(0x00, 0x40) 
            // Load the value from the computed storage slot.
            // This value is the balance of the sender.
            // Store the result in a variable named 'senderBalance'.
            let senderBal := sload(slot)
            // Check that the sender's balance is greater than or equal to the amount to transfer.
            // If it is not, revert the transaction. Use the 'lt' (less than) operation to compare the balance and the amount.
            // Then, use the 'jumpi' operation to conditionally jump to a failure label if the balance is not sufficient.
            if lt(senderBal, amount) {
                revert(0, 0)
            }
            // Subtract the transfer amount from the sender's balance.
            // Store the updated balance back into the sender's balance storage slot.
            let updatedSenderBal := sub(senderBal, amount)
            sstore(slot, updatedSenderBal)

            // Repeat similar steps to calculate the storage slot for the recipient's balance,
            // load the recipient's balance, add the transfer amount to it, and store the updated balance back into storage.
            
            // Return true at the end of the function to indicate success.
        }
    }
}
