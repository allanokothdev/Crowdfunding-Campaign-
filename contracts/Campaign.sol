pragma solidity ^0.5.0;

import "./Ownable.sol";

contract Campaign is Ownable {

//VARIABLES

//Project OBJECT
  struct Project {
    uint id;   //Unique ID
    string title;
    address creator;
    uint goal;
    uint pledges;
    mapping (address => uint) balance;
    uint deadline;
    bool status;
  }

//LIST OF Project IDs
  uint public ProjectCounter;

//Initialize pledges mapping for every project
    mapping (address => uint) pledgeBalance;

//LIST Of Project
  mapping (uint => Project) projects;

//EVENTS
  event completedProject(uint indexed _id);

  event FundProject(uint indexed _id, address indexed _funder, uint _amountFund, uint _pledgeFund);

  event GenerateProject(uint indexed _id, address indexed _creator, uint _goal, uint _pledged, uint _deadline);

  event FundTransfer(uint indexed _id, address indexed _creator, uint _pledges, bool _status);

  constructor() public {
      ProjectCounter = 0;
  }

//MODIFIERS
  modifier isActive(uint _id) {require(!projects[_id].status);_;}

  modifier onlyCreator(uint _id) {require(msg.sender == projects[_id].creator);_;}

//Project Creation
  function createProject(string memory _title, uint _goal) public {
    ProjectCounter++;
    projects[ProjectCounter] = Project(ProjectCounter, _title, msg.sender, _goal, 0 ,fetchDeadline(now), false);
    emit GenerateProject(ProjectCounter, msg.sender, _goal, 0, fetchDeadline(now));
  }

//Calculate Campign Deadline Date | Can be accessed by function
  function fetchDeadline(uint _now) public pure returns (uint) {
    return _now + (3600 * 24 * 7);
  }


//Contribute Funds to the Project
  function fundProject(uint _id) payable isActive( _id ) public {
    projects[_id].pledges += msg.value;
    projects[_id].balance[msg.sender] += msg.value;
    emit FundProject(_id, msg.sender, msg.value, projects[_id].pledges);
  }

  function checkFundingGoal(uint _id) isActive(_id) onlyCreator(_id) public {
    //Fetch Project Object from mapping/List
    Project memory proje = projects[_id];

    //check if pledges have surpassed Project goal
    if(proje.goal <= proje.pledges){
      //Change Project status to True i.e. completed
      projects[_id].status = true;

      //SEND FUNDS To project creator
      msg.sender.transfer(proje.pledges);

      //NOTIFY
      emit FundTransfer(_id, msg.sender, projects[_id].pledges, projects[_id].status);

    } else {
      revert();
    }
  }

}
