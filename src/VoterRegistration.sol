// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract VoterRegistration {
    address public electoralBoard;
    mapping(address => bool) public registeredVoters;

    event VoterRegistered(address indexed voter);

    modifier onlyElectoralBoard() {
        require(msg.sender == electoralBoard, "Only Electoral board can perform this action");
        _;
    }

    constructor() {
        electoralBoard = msg.sender;
    }

    function registerVoter(address _voter) external onlyElectoralBoard {
        require(!registeredVoters[_voter], "Voter already Registered");
        registeredVoters[_voter] = true;
        emit VoterRegistered(_voter);
    }

    function isVoterRegistered(address _voter) external view returns (bool) {
        return registeredVoters[_voter];
    }
}

