//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

/**@title Ballot
 *@dev implements voting process along with vote delegation
 */
contract Ballot {

    address public chairperson;

    struct Voter {
        uint weight; //weight is accumulated and based on delegation
        bool voted; //true if person has voted
        address delegate; // person voting is delegated to
        uint vote; //index of the voted proposal
    } 

    struct Proposal {
        bytes32 name; //short name of proposal
        uint voteCount; //number of accumulated votes
    }


    //provides a bridge between the voter struct and all addres types
    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    //contract will be initialized with constructor and proposalNames
    constructor (bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;


        //loop through all the proposal names the contract is run with
        //add them to the proposals array as Proposal Structs that they are 
        for( uint i = 0; i< proposalNames.length; i++){
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }


    }

    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,"only chairperson can give the right to vote"
            );
        require(
            !voters[voter].voted, "voter has already voted"
        );
        require(voters[voter].weight == 0);

        voters[voter].weight = 1;
    }

    function delegate(address to){
        //create sender var of Voter type
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "you already voted");
        require(to!=msg.sender, "self delegation is dissallowed");

        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;
            require(to != msg.sender, "found loop in delegation");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to]
        if (delegate_.voted){
            proposals[delegate_.vote].voteCount +=sender.weight;
        }else {
            delegate_.weight +=sender.weight;
        }

    }

    function vote(uint proposal)external{
        //voter is person currently interacting with contract
        //store voters address in sender var to reuse
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "has no right to vote");
        require(!sender.voted, "already voted");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount +=sender.weight;

    }

    function winningProposal() public view returns (uint winningProposal_){
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;}
            }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external view returns (bytes32 winnerName_)
    {
    winnerName_ = proposals[winningProposal()].name;
    }
    
       
}