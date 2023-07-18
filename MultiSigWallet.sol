//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract MultiSigWallet {
    //events
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    //state variables
    address[] public owners;
    mapping(address => bool) public isOwner; //returns true for owner address
    uint public required;

    Transaction[] public transactions;
    //uint is the index of the transaction being approved
    mapping(uint => mapping(address => bool)) public approved;

    modifier onlyOwner(){
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }
    
    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    constructor(address[] memory _owners, uint _required){
        require(_owners.length >0, "owners required");
        require(_required > 0 && _required <= _owners.length,
        "invalid required number of owners"
        );

        for (uint i; i< _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique");

            isOwner[owner] = true;
            owners.push[owner];
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(address _to, uint value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false}));
        emit Submit(trasactions.length - 1);

    }
    //check if txExists as a modifier in the function modifier
    function approve(uint txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint _txId) private view returns(uint count) {
        for (uint i; i < owners.length, i++) {
            if approved[_txId][owners[i]]{
                count +=1;
            }
        }
    }

}