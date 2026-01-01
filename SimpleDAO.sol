// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(address user) external view returns (uint256);
}

contract SimpleDAO {

    IERC20 public governanceToken;
    uint256 public proposalCount;
    uint256 public constant VOTING_DURATION = 3 days;

    constructor(address _token) {
        governanceToken = IERC20(_token);
    }

    struct Proposal {
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 deadline;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // 1️⃣ Create proposal
    function createProposal(string calldata _desc) external {
        proposalCount++;

        proposals[proposalCount] = Proposal({
            description: _desc,
            yesVotes: 0,
            noVotes: 0,
            deadline: block.timestamp + VOTING_DURATION,
            executed: false
        });
    }

    // 2️⃣ Vote
    function vote(uint256 _id, bool support) external {
        Proposal storage proposal = proposals[_id];

        require(block.timestamp < proposal.deadline, "Voting ended");
        require(!hasVoted[_id][msg.sender], "Already voted");

        uint256 votingPower = governanceToken.balanceOf(msg.sender);
        require(votingPower > 0, "No voting power");

        if (support) {
            proposal.yesVotes += votingPower;
        } else {
            proposal.noVotes += votingPower;
        }

        hasVoted[_id][msg.sender] = true;
    }

    // 3️⃣ Execute proposal
    function executeProposal(uint256 _id) external {
        Proposal storage proposal = proposals[_id];

        require(block.timestamp >= proposal.deadline, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(proposal.yesVotes > proposal.noVotes, "Proposal failed");

        proposal.executed = true;

        // Execution logic goes here
    }
}
