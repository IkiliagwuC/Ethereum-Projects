//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract HotelRoom {
    //keeps track of a collection of options that will never change
    //whether hotel room vacant or occupied
    enum Statuses {
        Vacant, 
        Occupied
    }

    Statuses currentStatus;

    event Occupy(address _occupant, uint _value);

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
        //initialize the contract with a vacant status
        currentStatus = Statuses.Vacant;
    }
    //modifiers run before the function is executed
    modifier onlyWhileVacant {
        //check status        
        //only allow booking when the room is currently vacant
        require(currentStatus == Statuses.Vacant, "currently occupied");
        _;
    }

    modifier costs(uint _amount){
        //check price
        require(msg.value >= _amount, "not enough ether provided");
        _;
    }


    receive() external payable onlyWhileVacant costs(2 ether){   
        //change status using enum
        currentStatus = Statuses.Occupied;
        //transfer eth to the contract owner/pay for hotel
        owner.transfer(msg.value);
        //emit Occupy event
        emit Occupy(msg.sender, msg.value);
    }