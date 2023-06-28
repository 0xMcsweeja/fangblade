// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Counter {
    uint256 private _count; // [Storage - at default location for state variable] This is implicitly at location 0x00 for a single variable contract

    // Function to set the value of the counter
    function setNumber(uint256 newNumber) public {
        _count = newNumber; // [Storage] Set the storage counter to the provided value
    }

    // Function to increment the counter by 1
    function increment() public {
        _count += 1; // [Storage] Increment the storage counter
    }

    // Optimized function to increment the counter using inline assembly
    function incrementOptimized() public {
        assembly {
            let count := sload(0)  // [Storage - at location 0x00] Load the value at storage slot 0 into a memory variable
            let incremented := add(count, 1) // [Memory] Increment the memory variable by 1
            sstore(0x00, incremented) // [Storage - at location 0x00] Store the incremented memory value back at storage slot 0
        }
    }
    
    // Function to get the value of the counter
    function getCount() public view returns (uint256) {
        return _count; // [Storage] Return the value of the storage counter
    }

    // Optimized function to get the counter's value using inline assembly
    function getCountOptimized() public view returns (uint256 result) {
        assembly {
            result := sload(0) // [Storage - at location 0x00] Load the value at storage slot 0 into the memory result variable
        }
    }


}
