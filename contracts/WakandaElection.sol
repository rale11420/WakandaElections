// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./WKND.sol";

contract WKNDElection {
    //events
    event NewChallenger(uint indexed id, string indexed name, uint votes);
    event Vote(address indexed voter, uint amount);
    event Registered(address indexed voter);
    //modifiers
    modifier onlyRegistered {
        require(registeredVoters[msg.sender],"Not voter");
        _;
    }

    modifier notDoneVoting {
        require(!doneVoting[msg.sender],"Not done voting");
        _;
    }

    struct Candidate {
        string name;
        uint age;
        string cult;
        uint numberOfVotes;
    }

    WKND public token;
    Candidate[] public votes;
    //[["Oneza Umbadi",56,"White Gorilla Cult",0],["K'Tashe Khotare",52,"Lion Cult",0],["W'Kasse Zomvu",67,"Lion Cult",0],["Amwea Thembunu",72,"White Gorilla Cult",0],["Ch'Tahni Chite",39,"White Gorilla Cult",0],["Mbosha Tabi",31,"Lion Cult",0],["Kwantak Buzakhi",65,"Hyena Clan",0],["Omeru Khibanda",43,"Panther Cult",0],["Iwi Tamva",72,"Crocodile Cult",0],["Jodi Tazediba",38,"White Gorilla Cult",0]]
    constructor(Candidate[] memory candidates) {
        token = new WKND();
        for(uint i = 0; i < candidates.length; i++){
            votes.push(candidates[i]);
        }
    }

    mapping(address => bool) public doneVoting;
    mapping(address => bool) public registeredVoters;
    mapping(address => uint) public peopleToVotes;

    function register() external notDoneVoting {
        require(!registeredVoters[msg.sender],"Registered already");
        registeredVoters[msg.sender] = true;

        token.approve(address(this), 1);
        token.transferFrom(address(this), msg.sender, 1);

        emit Registered(msg.sender);
    }

    function vote(uint candidateId, uint amount) external onlyRegistered notDoneVoting{
        require(token.balanceOf(msg.sender) >= amount);
        doneVoting[msg.sender] = true;

        (,,Candidate memory temp) = winingCandidates(votes);
        votes[candidateId].numberOfVotes += amount;         
        if(temp.numberOfVotes < votes[candidateId].numberOfVotes){
            emit NewChallenger(candidateId,votes[candidateId].name, votes[candidateId].numberOfVotes);
        }

        peopleToVotes[msg.sender] = candidateId;

        token.transfer(address(this),1);

        emit Vote(msg.sender, amount);
    }

    function getBalance(address user) external view returns(uint) {
        return token.balanceOf(user);
    }
    
    function winingCandidates(Candidate[] memory _tempVotes) public view returns(Candidate memory, Candidate memory, Candidate memory) {
        for(uint i = 0; i < _tempVotes.length - 1; i++){
            for(uint j = i + 1; j < _tempVotes.length; j++){
                if(_tempVotes[j].numberOfVotes > _tempVotes[i].numberOfVotes){
                    Candidate memory temp = _tempVotes[i];
                    _tempVotes[i] = _tempVotes[j];
                    _tempVotes[j] = temp;
                }
            }
        }
        Candidate memory a = _tempVotes[0];
        Candidate memory b = _tempVotes[1];
        Candidate memory c = _tempVotes[2];

        return (a,b,c);
    }
}