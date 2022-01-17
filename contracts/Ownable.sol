pragma solidity ^0.5.0;

contract Ownable {
  address admin;

  modifier onlyOwner() {
    require(msg.sender == admin);
    _;
  }

  constructor Ownable (){
    admin = msg.sender;
  }
}
