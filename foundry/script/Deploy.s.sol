// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import "contracts/token/MyToken.sol";
import "contracts/governance_standard/TimeLock.sol";
import "contracts/governance_standard/GovernorContract.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // deploy token
        MyToken token = new MyToken(msg.sender);
        console.log("Token deployed to:", address(token));

        // deploy timelock
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        address admin = address(0);
        uint256 minDelay = 3600;

        TimeLock timeLock = new TimeLock(minDelay, proposers, executors, admin);
        console.log("TimeLock deployed to:", address(timeLock));

        // deploy governor
        uint256 votingDelay = 1;
        uint256 votingPeriod = 45818;
        uint256 quorumPercentage = 4;

        GovernorContract governor = new GovernorContract(
            token,
            timeLock,
            votingDelay,
            votingPeriod,
            quorumPercentage
        );
        console.log("Governor deployed to:", address(governor));

        vm.stopBroadcast();
    }
}
