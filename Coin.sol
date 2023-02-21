//SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 <=0.9.0;

contract Coin {
    //public makes variables accessible from other contracts
    address public minter;
    mapping(address => uint256) public balances;

    //events allow clients(programs) to react to changes you declare
    event Sent(address from, address to, uint256 amount);

    //constructor is called only when the contract is created
    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint256 amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    //to the caller of the function
    error InsufficientBalance(uint256 requested, uint256 available);

    function send(address receiver, uint256 amount) public {
        if (amount > balances[msg.sender])
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}
