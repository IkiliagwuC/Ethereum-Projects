//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    uint256 counter;

    //constructor runs once whenever the function is called
    constructor() {
        counter = 0;
    }

    //function increments the count by 1
    function incrementCounter() public {
        counter = counter + 1;
    }

    function decrementCounter() public {
        counter = counter - 1;
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }
}
