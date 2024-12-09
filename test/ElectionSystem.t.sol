// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/VoterRegistration.sol";
import "../src/ElectionFactory.sol";
import "../src/Election.sol";

contract ElectionSystemTest is Test {
    VoterRegistration public voterRegistration;
    ElectionFactory public electionFactory;
    Election public lagosElection;

    address public electoralBoard;
    address public voter1;
    address public voter2;
    address public voter3;

    function setUp() public {
        electoralBoard = address(1);
        voter1 = address(2);
        voter2 = address(3);
        voter3 = address(4);

        vm.startPrank(electoralBoard);
        voterRegistration = new VoterRegistration();
        electionFactory = new ElectionFactory(address(voterRegistration));
        vm.stopPrank();
    }

      function testElectionLifecycle() public {
        // Register voters
        vm.startPrank(electoralBoard);
        voterRegistration.registerVoter(voter1);
        voterRegistration.registerVoter(voter2);
        voterRegistration.registerVoter(voter3);
        vm.stopPrank();

        // Deploy Lagos election
        vm.prank(electoralBoard);
        electionFactory.deployElection("Lagos");

        // Get Lagos election address
        (, address electionAddress) = electionFactory.deployedElections(0);
        lagosElection = Election(electionAddress);

        // Add candidates
        string[] memory candidates = new string[](2);
        candidates[0] = "Candidate A";
        candidates[1] = "Candidate B";
        vm.prank(electoralBoard);
        electionFactory.addCandidatesToElection(address(lagosElection), candidates);

        // Delegate vote
        vm.prank(voter2);
        lagosElection.delegateVote(voter1);

        // Cast votes
        vm.prank(voter1);
        lagosElection.vote(0); // Vote for Candidate A
        vm.prank(voter3);
        lagosElection.vote(1); // Vote for Candidate B

        // End election
        vm.prank(address(electionFactory));
        lagosElection.endElection();

        // Get winner
        string memory winner = lagosElection.getWinner();
        assertEq(winner, "Candidate A", "Unexpected winner");
    }
}

