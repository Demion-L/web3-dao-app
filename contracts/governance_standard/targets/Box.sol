// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Box
 * @dev A simple contract that will be controlled by the TimeLock contract
 * @notice This contract serves as an example of a contract that can be governed
 * through the TimeLock mechanism. The value can only be changed through
 * a governance proposal that passes through the TimeLock contract.
 */
contract Box {
    uint256 public value;

    /**
     * @dev Sets the value of the box
     * @param _value The new value to set
     * @notice This function will be called through the TimeLock contract
     * after a successful proposal and delay period
     */
    function setValue(uint256 _value) public {
        value = _value;
    }
}
