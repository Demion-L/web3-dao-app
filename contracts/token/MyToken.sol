// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20Votes, Ownable {
    string public constant VERSION = "0.1.0";
    uint256 private constant MAX_SUPPLY = 10_000_000 * 1e18;

    modifier validSpenderAndAmount(address account, uint256 amount) {
        require(account != address(0), "Cannot use the zero address");
        require(amount > 0, "Amount must be greater than zero");
        _;
    }

    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor() ERC20Votes("MyToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 1e18); // This _mint call will use ERC20Votes._mint
        // renounceOwnership(); // Consider if you want this immediately
    }

    function mint(
        address to,
        uint256 amount
    ) external onlyOwner validSpenderAndAmount(to, amount) {
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "Minting exceeds max supply"
        );
        _mint(to, amount); // This _mint call will use ERC20Votes._mint
        emit TokensMinted(to, amount);
    }

    function approve(
        address spender,
        uint256 amount
    )
        public
        override(ERC20Votes)
        validSpenderAndAmount(spender, amount)
        returns (bool)
    {
        require(balanceOf(msg.sender) >= amount, "Approval exceeds balance");
        return super.approve(spender, amount);
    }

    // You need to override _update because ERC20Votes is also virtual and expects it to be handled.
    // Or rather, ERC20Votes overrides _update from ERC20 and makes it virtual again or has multiple paths.
    // The exact override rules can be complex, but the compiler usually guides you.
    // In newer OZ versions, _update is the core function that _mint, _burn, _transfer call.
    // ERC20Votes overrides _update. If you also override it, you'd specify ERC20Votes.
    // But here, for _mint and _burn, it's simpler.

    // If you want the TokensBurned event, you need to override _burn:
    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._burn(account, amount);
        emit TokensBurned(account, amount);
    }

    // For _afterTokenTransfer, if you're not adding custom logic, you might not need to override it here.
    // ERC20Votes's version will be used.
    // If you DO need to override it for some reason (e.g., custom logic), it would be:
    // function _afterTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) internal virtual override(ERC20Votes) { // Note: ERC20Votes._afterTokenTransfer is virtual
    //     super._afterTokenTransfer(from, to, amount);
    // }
    // Same for _mint if you were overriding it and not just calling it.
    // The functions you call like `_mint()` in your constructor and `mint()` function
    // will resolve to `ERC20Votes._mint()` which is what you want.
}
