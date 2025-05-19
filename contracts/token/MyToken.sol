// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

string public constant VERSION = "0.1.0";

contract MyToken is ERC20Votes, Ownable {
    // Max supply cap
    uint256 private constant MAX_SUPPLY = 10_000_000 * 1e18; // 10 million tokens

    // Moddifiers 
    modifier validSpenderAndAmount(address account, uint256 amount) {
        require(account != address(0), "Cannot use the zero address");
        require(amount > 0, "Amount must be greater than zero");
        _;
    }
    modifier sufficientBalance(address account, uint256 amount) {
    require(balanceOf(account) >= amount, "Insufficient balance");
    _;
}

    // Events to log important actions
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    // Constructor to initialize the token with a name and symbol
    // and mint an initial supply to the deployer
    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {
        _mint(msg.sender, 1_000_000 * 1e18);
        renounceOwnership(); // No more owner control
    }

    // Override to allow minting by owner only (optional)
    function mint(
        address to,
        uint256 amount
    ) external onlyOwner validSpenderAndAmount(to, amount) {
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "Minting exceeds max supply"
        );
        _mint(to, amount);
        // Emit the TokensMinted event
        emit TokensMinted(to, amount);
    }

    // Function approve to allow a spender to spend tokens on behalf of the owner
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) validSpenderAndAmount(spender, amount) {
  
        require(
            balanceOf(msg.sender) >= amount,
            "Approval amount exceeds balance"
        );

        bool success = super.approve(spender, amount);

        // Emit the Approval event
        emit Approval(msg.sender, spender, amount);
        return success;
    }

    // The following functions are overrides required by Solidity
    function delegate(address delegatee) public override {
        super.delegate(delegatee);
    }

    // function _afterTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) internal override(ERC20Votes) {
    //     super._afterTokenTransfer(from, to, amount);
    // }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20Votes, ERC20) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    )
        internal
        override(ERC20Votes, ERC20)
        validSpenderAndAmount(account, amount) 
        {
        require(balanceOf(account) >= amount, "Burn amount exceeds balance");
        // Call the parent _burn function
        super._burn(account, amount);

        // Emit the Transfer event for burn
        emit Transfer(account, address(0), amount);
        // Emit the TokensBurned event
        emit TokensBurned(account, amount);
    }
}
