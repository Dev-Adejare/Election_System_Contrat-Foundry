// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Election.sol";
import "./VoterRegistration.sol";

contract ElectionFactory {
    struct DeployedElection {
        string stateName;
        address electionAddress;
    }

    VoterRegistration public voterRegistration;
    DeployedElection[] public deployedElections;

    event ElectionDeployed(string stateName, address electionAddress);

    constructor(address _voterRegistrationAddress) {
        voterRegistration = VoterRegistration(_voterRegistrationAddress);
    }

    function deployElection(string memory _stateName) external {
        Election newElection = new Election(_stateName, address(voterRegistration));
        deployedElections.push(DeployedElection(_stateName, address(newElection)));
        emit ElectionDeployed(_stateName, address(newElection));
    }

    function addCandidatesToElection(address _electionAddress, string[] memory _candidates) external {
        Election election = Election(_electionAddress);
        for (uint256 i = 0; i < _candidates.length; i++) {
            election.addCandidate(_candidates[i]);
        }
    }

    function getAllElections() external view returns (DeployedElection[] memory) {
        return deployedElections;
    }
}

