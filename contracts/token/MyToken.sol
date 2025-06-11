// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract MyToken is ERC20, ERC20Votes, Ownable {
    uint256 public constant s_maxSupply = 1000000 * 10 ** 18; // 1 million tokens

    constructor(
        address initialOwner
    ) ERC20("MyToken", "MTK") Ownable(initialOwner) EIP712("MyToken", "1") {
        // Mint the entire supply to the initial owner
        _mint(initialOwner, s_maxSupply);
    }

    // Override required by Solidity for multiple inheritance
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }
}
