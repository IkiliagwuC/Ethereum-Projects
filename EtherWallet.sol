//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);

    }

    receive() external payable {

    }

    function withdraw(uint _amount) external {
        require(owner == msg.sender, "only owner can withdraw");
        //payable(owner).transfer(_amount);
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "failed to send ether");
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}