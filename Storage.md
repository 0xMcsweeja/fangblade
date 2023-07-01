# Layout in Storage
---
## Overview

State variables of contracts are stored in storage in a compact way. Data is stored contiguously, except for dynamically-sized arrays and mappings. Variables are stored starting with the first state variable in slot `0`. Storage slots are 32 bytes, and multiple values can be packed into a single storage slot if they are smaller than 32 bytes.

## Rules for Storage Layout

- The first item in a storage slot is stored lower-order aligned.
- Value types use only as many bytes as necessary.
- If a value type doesn't fit the remaining part of a storage slot, it is stored in the next slot.
- Structs and array data always start a new slot.
- Items following struct or array data always start a new storage slot.

## Inheritance and Storage Layout

For contracts using inheritance, the ordering of state variables is determined by the C3-linearized order of contracts starting with the most base-ward contract. State variables from different contracts can share the same storage slot if allowed by the rules.

## Structs and Arrays

Elements of structs and arrays are stored contiguously just like individual values. 

*Note:* When using elements smaller than 32 bytes, gas usage may be higher because EVM operates on 32 bytes. The compiler will pack multiple elements into one storage slot, combining multiple reads or writes into a single operation. 

Ordering storage variables and struct members for tight packing is recommended. For example, `uint128, uint128, uint256` is more efficient than `uint128, uint256, uint128`.

## Mappings and Dynamically-sized Arrays

Mappings and dynamically-sized arrays cannot be stored in between state variables due to their unpredictable size. They are considered to occupy only 32 bytes and are stored starting at a different storage slot computed using a Keccak-256 hash.

For dynamic arrays, the slot stores the number of elements. For mappings, the slot stays empty.

- Array data is located starting at `keccak256(p)`.
- Mapping key `k` data is located at `keccak256(h(k) . p)`.

Here `p` is the storage slot, and `h` is a function applied to the key depending on its type.

## Bytes and Strings

`bytes` and `string` types are encoded identically. The encoding is similar to `bytes1[]`.

## Example with Struct and Mapping

Consider the contract:

```solidity
contract C {
    struct S { uint16 a; uint16 b; uint256 c; }
    uint x;
    mapping(uint => mapping(uint => S)) data;
}
```

To compute the storage location of `data[4][9].c`, let's assume the position of the mapping itself is `1`. Then, `data[4]` is stored at `keccak256(uint256(4) . uint256(1))`. The type of `data[4]` is again a mapping, and the data for `data[4][9]` starts at slot `keccak256(uint256(9) . keccak256(uint256(4) . uint256(1)))`. The slot offset of the member `c` inside the struct `S` is `1` because `a` and `b` are packed in a single slot. This means the slot for `data[4][9].c` is `ke

`keccak256(uint256(9) . keccak256(uint256(4) . uint256(1))) + 1`. The type of the value is `uint256`, so it uses a single slot.

---
[official documentation](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html).