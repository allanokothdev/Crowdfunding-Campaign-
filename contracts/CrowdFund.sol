pragma solidity ^0.5.0;

import "./Ownable.sol";

contract Campaign is Ownable {

//VARIABLES

//CAMPAIGN OBJECT
  struct Campaign {
    uint id;   //Unique ID
    string title;
    address creator;
    uint goal;
    uint pledges;
    mapping (address => uint) balance;
    uint deadline;
    bool status;
  }

//CONTRACT DEPLOYER address
  address public admin;

//LIST OF Campaign IDs
  uint public campaignCounter;

//LIST Of Campaign
  mapping (uint => Campaign) campaigns;

//EVENTS
  event completedCampaign(uint indexed _id);

  event FundCampaign(uint indexed _id, address indexed _funder, uint _amountFund, uint _pledgeFund);

  event GenerateCampaign(uint indexed _id, address indexed _creator, uint _goal, uint _pledged, uint _deadline);

  event FundTransfer(uint indexed _id, address indexed _creator, uint _pledges, bool _status);

  constructor Campaign () {
    msg.sender = admin;
    projectCounter = 0;
  }

//MODIFIERS
  modifier isActive(uint memory _id) {require(!campaigns[_id].status);_;}

  modifier onlyCreator(uint _id) {require(msg.sender == campaigns[_id].creator);_;}

//Campaign Creation
  function createCampaign(string memory _title, uint memory _goal) public {
    campaignCounter++;
    campaigns[campaignCounter] = Campaign(campaignCounter, _title, msg.sender, _goal, 0, fetchDeadline(now), false);
    GenerateCampaign(campaignCounter, msg.sender, _goal, 0, fetchDeadline(now));
  }

//Calculate Campign Deadline Date | Can be accessed by function
  function fetchDeadline(uint memory _now) public pure returns (uint) {
    return _now + (3600 * 24 * 7);
  }


//Contribute Funds to the Campaign
  function fundCampaign(uint memory _id) payable isActive( _id ) public {
    campaigns[_id].pledges += msg.value;
    campaigns[_id].balance[msg.sender] += msg.value;
    FundCampaign(_id, msg.sender, msg.value, campaigns[_id].pledges);
  }

  function checkFundingGoal(uint _id) isActive(_id) onlyCreator(_id) public {
    //Fetch Campaign Object from mapping/List
    Campaign memory campaign = campaigns[_id];

    //check if pledges have surpassed campaign goal
    if(campaign.goal <= campaign.pledges){
      //Change Campaign status to True i.e. completed
      campaigns[_id].status = true;

      //SEND FUNDS To project creator
      msg.sender.send(campaign.pledges);

      //NOTIFY
      FundTransfer(_id, msg.sender, campaigns[_id].pledges, campaigns[_id].status);

    } else {
      revert();
    }
  }

}
