// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/VoterRegistration.sol";
import "../src/ElectionFactory.sol";

contract DeployElectionSystem is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        

        // Deploy VoterRegistration contract
        VoterRegistration voterRegistration = new VoterRegistration();
        console.log("VoterRegistration deployed at:", address(voterRegistration));

        // Deploy ElectionFactory contract
        ElectionFactory electionFactory = new ElectionFactory(address(voterRegistration));
        console.log("ElectionFactory deployed at:", address(electionFactory));

        vm.stopBroadcast();
    }
}