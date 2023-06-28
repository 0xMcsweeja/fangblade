// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function testIncrement() public {
        uint256 initialGas = gasleft(); // Get initial gas
        for (uint256 i = 0; i < 100; i++) {
            counter.increment();
        }
        uint256 finalGas = gasleft();
        uint256 gasUsed = initialGas - finalGas;
        console.log("Gas used in testIncrement:", gasUsed);
        assertEq(counter.getCount(), 100);
    }

    function testIncrementOptimized() public {
        uint256 initialGas = gasleft(); // Get initial gas
        for (uint256 i = 0; i < 100; i++) {
            counter.incrementOptimized();
        }
        uint256 finalGas = gasleft();
        uint256 gasUsed = initialGas - finalGas;
        console.log("Gas used in testIncrementOptimized:", gasUsed);
        assertEq(counter.getCount(), 100);
    }

    function testSetNumberParameterizer() public pure returns (uint256) {
        return 5; // This is the value that will be used for `x` in testSetNumber
    }

    function testSetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.getCount(), x);
    }

    function testGetCountOptimized() public {
        counter.increment(); // increments counter to 1
        counter.incrementOptimized(); // increments counter to 2
        assertEq(counter.getCountOptimized(), 2); // should return 2
    }
}
