# Layout in Storage
---
## Overview

State variables of contracts are stored in storage in a compact way. Data is stored contiguously, except for dynamically-sized arrays and mappings. Variables are stored starting with the first state variable in slot `0`. Storage slots are 32 bytes, and multiple values can be packed into a single storage slot if they are smaller than 32 bytes.

## Rules for Storage Layout

Here is a table summarizing the rules for storage layout:

| Rule | Description |
|------|-------------|
| Alignment | The first item in a storage slot is stored lower-order aligned. |
| Value Types | Value types use only as many bytes as necessary. |
| Spillover | If a value type doesn't fit the remaining part of a storage slot, it is stored in the next slot. |
| Structs and Arrays | Structs and array data always start a new slot. |
| Following Items | Items following struct or array data always start a new storage slot. |

## Inheritance and Storage Layout

For contracts using inheritance, the ordering of state variables is determined by the C3-linearized order of contracts starting with the most base-ward contract. State variables from different contracts can share the same storage slot if allowed by the rules.

## Structs and Arrays

Elements of structs and arrays are stored contiguously just like individual values. 

🚨 **Warning:** When using elements smaller than 32 bytes, gas usage may be higher because EVM operates on 32 bytes. The compiler will pack multiple elements into one storage slot, combining multiple reads or writes into a single operation.

👉 **Tip:** Order storage variables and struct members for tight packing. For example:

```
// Efficient
uint128, uint128, uint256

// Less Efficient
uint128, uint256, uint128
```

The first example will only take up two slots of storage whereas the second will take up three.

## Mappings and Dynamically-sized Arrays

Mappings and dynamically-sized arrays have special storage considerations:

| Type | Storage Consideration |
|------|----------------------|
| Mappings | Considered to occupy only 32 bytes. The slot stays empty. |
| Dynamically-sized Arrays | The slot stores the number of elements. |

They are stored at a different storage slot computed using a Keccak-256 hash. For dynamic arrays, this is `keccak256(p)` and for mapping key `k`, this is `keccak256(h(k) . p)`. Here `p` is the storage slot, and `h` is a function applied to the key depending on its type.

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

To compute the storage location of `data[4][9].c`, follow these steps:

1. Compute position of the mapping: `keccak256(uint256(4) . uint256(1))`.
2. Compute slot for `data[4][9]`: `keccak256(uint256(9) . keccak256(uint256(4) . uint256(1)))`.
3. Compute slot for `data[4][9].c`: `keccak256(uint

256(9) . keccak256(uint256(4) . uint256(1))) + 1`.

## Visual Representation

Consider this simple contract:

```solidity
contract SimpleStorage {
    uint8 a;
    uint16 b;
    uint32 c;
    uint d;
}
```

The state variables would be stored in slots as follows:

```
+-------------------------+ Slot 0
|            a            |
|            b            |
|            c            |
+-------------------------+
+-------------------------+ Slot 1
|            d            |
+-------------------------+
```

Now, if we change the types of `a`, `b`, and `c` to `uint256`, they would each occupy a new slot:

```
+-------------------------+ Slot 0
|            a            |
+-------------------------+
+-------------------------+ Slot 1
|            b            |
+-------------------------+
+-------------------------+ Slot 2
|            c            |
+-------------------------+
+-------------------------+ Slot 3
|            d            |
+-------------------------+
```

This visually represents how smaller data types are packed into a single slot, while larger data types occupy entire slots.

---
[official documentation](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html).