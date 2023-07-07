//SPDX-License-Identifier: MIT;

pragma solidity ^0.8.18;

contract SendEther {
    //1.Transfer returns all gas and reverts on failure
    function sendViaTransfer(address payable _to) public payable {
        //this is no longer the recommended way to send ether
        _to.transfer(msg.value);
    }

    //2.Send returns bool indicating success or failure and continues executing
    function sendViaSend(address payable _to) public payable {
        bool sent = _to.send(msg.value);
        require(sent, "failed to send ether");
    }

    function sendViaCall(address payable _to) public payable {
        //returns bool indicating success or failure
        //this is the current recommended sending method.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "failed to send ether");
    }
}
