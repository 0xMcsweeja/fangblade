// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/solady/src/tokens/ERC1155.sol";

contract Pfp is ERC1155 {
    constructor() ERC1155() {}

    function uri(
        uint256 id
    ) public view virtual override returns (string memory) {}
}
