pragma solidity ^0.5.0;

contract Ownable {

    address admin;

    constructor() public {

    }

    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

}
