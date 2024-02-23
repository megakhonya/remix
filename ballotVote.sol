// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ballot {
    struct Voter {
        uint256 vote;
        bool voted;
        uint256 weight;
    }

    struct Proposal {
        bytes32 name; // the name of each proposal
        uint256 voteCount; // the number of accumulated votes
    }

    Proposal[] public proposals;
    mapping(address => Voter) public voters;
    address public chairPerson;

    // Events
    event VoteCasted(address indexed voter, uint256 proposalIndex);

    modifier onlyChairperson() {
        require(msg.sender == chairPerson, "Only the ChairPerson can perform this action");
        _;
    }

    constructor(bytes32[] memory proposalNames) {
        chairPerson = msg.sender;
        voters[chairPerson].weight = 1;

        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    function giveRightToVote(address voter) public onlyChairperson {
        require(!voters[voter].voted, "The voter has already voted");
        require(voters[voter].weight == 0, "Voter already has voting rights");

        voters[voter].weight = 1;
    }

    function vote(uint256 proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Sender has no right to vote");
        require(!sender.voted, "Sender already voted");

        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;

        emit VoteCasted(msg.sender, proposal);
    }

    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

    function winningName() public view returns (bytes32 winningName_) {
        winningName_ = proposals[winningProposal()].name;
    }
}
