// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./VoterRegistration.sol";

contract Election {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    VoterRegistration public voterRegistration;
    address public factory;
    string public stateName;
    bool public electionClosed;

    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;
    mapping(address => address) public delegations;
    mapping(address => uint256) public voteWeight;

    event VoteCast(address indexed voter, uint256 candidateIndex);
    event VoteDelegated(address indexed from, address indexed to);
    event CandidateAdded(string name);
    event ElectionEnded(string winnerName);

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory can perform this action");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(voterRegistration.isVoterRegistered(msg.sender), "Not a registered voter");
        _;
    }

    modifier electionOpen() {
        require(!electionClosed, "Election is closed");
        _;
    }

    constructor(string memory _stateName, address _voterRegistrationAddress) {
        factory = msg.sender;
        stateName = _stateName;
        voterRegistration = VoterRegistration(_voterRegistrationAddress);
    }

    function addCandidate(string memory _name) external onlyFactory {
        candidates.push(Candidate(_name, 0));
        emit CandidateAdded(_name);
    }

    function delegateVote(address _to) external onlyRegisteredVoter electionOpen {
        require(_to != msg.sender, "Cannot delegate to self");
        require(!hasVoted[msg.sender], "Already voted");
        require(delegations[msg.sender] == address(0), "Already delegated");

        address delegate = _to;
        while (delegations[delegate] != address(0)) {
            delegate = delegations[delegate];
            require(delegate != msg.sender, "Found circular delegation");
        }

        delegations[msg.sender] = _to;
        if (!hasVoted[_to]) {
            voteWeight[_to] += voteWeight[msg.sender] > 0 ? voteWeight[msg.sender] : 1;
        } else {
            candidates[hasVoted[_to] ? 1 : 0].voteCount += voteWeight[msg.sender] > 0 ? voteWeight[msg.sender] : 1;
        }

        voteWeight[msg.sender] = 0;
        emit VoteDelegated(msg.sender, _to);
    }

    function vote(uint256 _candidateIndex) external onlyRegisteredVoter electionOpen {
        require(!hasVoted[msg.sender], "Already voted");
        require(_candidateIndex < candidates.length, "Invalid candidate index");

        hasVoted[msg.sender] = true;
        uint256 weight = voteWeight[msg.sender] > 0 ? voteWeight[msg.sender] : 1;
        candidates[_candidateIndex].voteCount += weight;

        emit VoteCast(msg.sender, _candidateIndex);
    }

    function endElection() external onlyFactory {
        electionClosed = true;
        emit ElectionEnded(getWinner());
    }

    function getWinner() public view returns (string memory) {
        require(electionClosed, "Election is not closed yet");
        uint256 winningVoteCount = 0;
        uint256 winningCandidateIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateIndex = i;
            }
        }

        return candidates[winningCandidateIndex].name;
    }
}

