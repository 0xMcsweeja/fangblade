/*
Project: ERC20 Assembly

This project aims to implement an ERC20 token using Solidity assembly for efficiency. 
The ERC21 token has the same interfaces as ERC20 but implemented with assembly code where possible. 
This project serves as a learning tool to understand low-level Ethereum Virtual Machine (EVM) operations and their gas efficiency.

- [x] `balanceOf`
- [x] `transfer`
- [x] `totalSupply`
- [x] `approve`
- [x] `allowance`
- [x] `transferFrom`
- [x] `increaseAllowance`
- [x] `decreaseAllowance`
- [x] `mint`

Storage Layout:
-------------------------------------
|   Slot   |  Description            |
|----------|-------------------------|
|   0x00   | (unused)                |
|   0x01   | _TOTAL_SUPPLY_POSITION  |
|   0x02   |   _BALANCES_POSITION    |
|   0x03   |  _ALLOWANCES_POSITION   |
--------------------------------------
*/
pragma solidity ^0.8.0;

contract ERC21 {
    uint256 private constant _BALANCES_POSITION = 0x02;
    uint256 private constant _ALLOWANCES_POSITION = 0x03;
    uint256 private _TOTAL_SUPPLY_POSITION;

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
            // Get the address of the sender
            let senderAdr := caller()

            // Hash the sender's address with the balances position to get the storage slot
            mstore(0x0, senderAdr)
            mstore(0x20, _BALANCES_POSITION)
            let senderSlot := keccak256(0x0, 0x40)

            // Load the sender's balance from storage
            let senderBal := sload(senderSlot)

            // Revert the transaction if the sender does not have enough balance
            if lt(senderBal, amount) { revert(0, 0) }

            // Subtract the amount from the sender's balance and store the updated balance
            let updatedSenderBal := sub(senderBal, amount)
            sstore(senderSlot, updatedSenderBal)

            // Hash the recipient's address with the balances position to get the storage slot
            mstore(0x0, recipient)
            mstore(0x20, _BALANCES_POSITION)
            let recipientSlot := keccak256(0x0, 0x40)

            // Load the recipient's balance, add the amount, and store the updated balance
            let recipientBal := sload(recipientSlot)
            sstore(recipientSlot, add(recipientBal, amount))
        }

        // Indicate that the transfer was successful
        return true;
    }

    /*  
        1. Get the address of the token owner, i.e., the caller of this function.
        2. Store the token owner's address, the spender's address, and the _ALLOWANCES_POSITION constant in suitable memory slots.
        3. Hash the token owner's address, the spender's address, and the _ALLOWANCES_POSITION together to get the storage slot for the allowance.
        4. Store the amount into the calculated allowance slot.
    */
    function approve(address spender, uint256 amount) public returns (bool) {
        assembly {
            // 1. You need the 'caller' function to get the address of the current function invoker (token holder)
            // Store this address in a suitable memory slot.
            let owner := caller()
            // 2. Store the `spender` address and the _ALLOWANCES_POSITION constant in suitable memory slots.
            mstore(0x00, owner) // caller address
            mstore(0x20, spender)
            mstore(0x40, _ALLOWANCES_POSITION)
            // 3. Hash the token holder's address, the `spender` address, and _ALLOWANCES_POSITION together
            let slot := keccak256(0x00, 0x60)
            // 4. Store the `amount` into the allowance slot obtained in the previous step.
            sstore(slot, amount)
            // 5. Emit the Approval event (You may skip this step as handling events in assembly is complex)
        }
        return true;
    }

    /*
        Assembly logic:
        1. Calculate the storage slot for the allowance of the `spender` for `owner`'s tokens.
        2. This involves hashing the `owner`'s address, `spender`'s address, and the _ALLOWANCES_POSITION together.
        3. Load the allowance from the computed slot.
        4. Return the loaded value.
    */
    function allowance(address owner, address spender) public view returns (uint256) {
        uint256 remaining;
        assembly {
            mstore(0x00, owner)
            mstore(0x20, spender)
            mstore(0x40, _ALLOWANCES_POSITION)
            let slot := keccak256(0x00, 0x60)
            remaining := sload(slot)
        }
        return remaining;
    }
    /*
    Assembly logic:
    1. Calculate the storage slots for the allowances, balances of the `from` address, and the recipient.
    2. Load the allowance of the `spender` for the `from` address and check if it is sufficient for the transfer.
    3. If so, subtract the amount from the allowance and store the updated allowance in its slot.
    4. Load the balance of the `from` address and check if it is sufficient for the transfer.
    5. If so, subtract the amount from the balance and store the updated balance in its slot.
    6. Finally, add the amount to the recipient's balance and store the updated balance in its slot.
    7. If any of the checks fail, revert the transaction.
    */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        assembly {
            // Check the spender's allowance
            // ------------------------------
            // 1. Load the caller's address (which is the spender) into a memory slot.
            // 2. Load the `from` address into another memory slot.
            // 3. Load the `_ALLOWANCES_POSITION` constant into yet another memory slot.
            // 4. Calculate the keccak256 hash of the spender's address, the `from` address, and `_ALLOWANCES_POSITION` to get the storage slot of the allowance.
            // 5. Load the value of the allowance from the computed storage slot.
            // 6. Check if the loaded allowance is less than `value`. If it is, revert the transaction.
            mstore(0x00, caller())
            mstore(0x20, from)
            mstore(0x40, _ALLOWANCES_POSITION)
            let spenderSlot := keccak256(0x00, 0x60)
            // Update the spender's allowance
            // ------------------------------
            // 7. If the allowance is sufficient, subtract `value` from the allowance.
            // 8. Store the updated allowance back to the computed storage slot.
            let allowanceVal := sload(spenderSlot)
            if lt(allowanceVal, value) { revert(0, 0) }
            sstore(spenderSlot, sub(allowanceVal, value))

            // Check and update the `from` address's balance
            // ----------------------------------------------
            // 9. Load the `from` address and `_BALANCES_POSITION` into memory slots.
            // 10. Calculate the keccak256 hash of the `from` address and `_BALANCES_POSITION` to get the storage slot of the `from` address's balance.
            // 11. Load the balance of the `from` address from the computed storage slot.
            // 12. Check if the loaded balance is less than `value`. If it is, revert the transaction.
            // 13. If the balance is sufficient, subtract `value` from the balance.
            // 14. Store the updated balance back to the computed storage slot.
            mstore(0x00, from)
            mstore(0x20, _BALANCES_POSITION)
            let slot := keccak256(0x00, 0x40)
            let fromBal := sload(slot)
            if lt(fromBal, value) { revert(0, 0) }
            sstore(slot, sub(fromBal, value))

            // Update the `to` address's balance
            // ---------------------------------
            // 15. Load the `to` address and `_BALANCES_POSITION` into memory slots.
            // 16. Calculate the keccak256 hash of the `to` address and `_BALANCES_POSITION` to get the storage slot of the `to` address's balance.
            // 17. Load the balance of the `to` address from the computed storage slot.
            // 18. Add `value` to the loaded balance.
            // 19. Store the updated balance back to the computed storage slot.
            mstore(0x00, to)
            let toSlot := keccak256(0x00, 0x40)
            let toBal := sload(toSlot)
            sstore(toSlot, add(toBal, value))
        }

        // Indicate that the transfer was successful
        return true;
    }

    /*
    Increase Allowance:
    1. Calculate the storage slot for the allowance.
    2. Load the current allowance.
    3. Add the input value to current allowance.
    4. Store the new allowance value.
    */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        assembly {
            // Calculate the storage slot for the allowance
            mstore(0x00, caller())
            mstore(0x20, spender)
            mstore(0x40, _ALLOWANCES_POSITION)
            let slot := keccak256(0x00, 0x60)

            // Load the current allowance value
            let currentAllowance := sload(slot)

            // Calculate the new allowance value
            let newAllowance := add(currentAllowance, addedValue)

            // Store the new allowance value
            sstore(slot, newAllowance)
        }

        return true;
    }

    /*
    Decrease Allowance:
    1. Calculate the storage slot for the allowance.
    2. Load the current allowance.
    3. Subtract input value from current allowance, revert if it's not enough.
    4. Store the new allowance value.
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        assembly {
            // Calculate the storage slot for the allowance
            mstore(0x00, caller())
            mstore(0x20, spender)
            mstore(0x40, _ALLOWANCES_POSITION)
            let slot := keccak256(0x00, 0x60)

            // Load the current allowance value
            let currentAllowance := sload(slot)

            // Check if subtractedValue is greater than the current allowance
            if gt(subtractedValue, currentAllowance) { revert(0, 0) }

            // Calculate the new allowance value
            let newAllowance := sub(currentAllowance, subtractedValue)

            // Store the new allowance value
            sstore(slot, newAllowance)
        }

        return true;
    }

    /*
    Mint:
    1. Load the current total supply.
    2. Compute and store the new total supply.
    3. Compute the storage slot for the balance of the account.
    4. Add the mint amount to account balance and store it.
    */
    function mint(address account, uint256 amount) public {
        assembly {
            let supply := sload(0x01)
            // Compute the storage slot for the `_TOTAL_SUPPLY` constant
            mstore(0x00, supply)
            let totalSupplySlot := keccak256(0x00, 0x20)

            // Load the current total supply
            let currentTotalSupply := sload(totalSupplySlot)

            // Compute the new total supply
            let newTotalSupply := add(currentTotalSupply, amount)

            // Store the new total supply
            sstore(totalSupplySlot, newTotalSupply)

            // Compute the storage slot for the balance of the account
            mstore(0x00, account)
            mstore(0x20, _BALANCES_POSITION)
            let balanceSlot := keccak256(0x00, 0x40)

            // Load the current balance of the account
            let currentBalance := sload(balanceSlot)

            // Compute the new balance
            let newBalance := add(currentBalance, amount)

            // Store the new balance
            sstore(balanceSlot, newBalance)
        }
    }
}
