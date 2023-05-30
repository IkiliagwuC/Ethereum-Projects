// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract BlindAuction {
    //pattern of bidding contracts
    //declare bid and how the bid can be sent
    //declare beneficiary with address
    //declaration of errors to be used later
    //show highest bidder //withdrawal of the highest bids
    //send bid to beneficiary

    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    address payable public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;
    event AuctionEnded(address winner, uint highestBid);

    // Errors that describe failures.
    /// The function has been called too early.
    /// Try again at `time`.
    error TooEarly(uint time);

    /// The function has been called too late.
    /// It cannot be called after `time`.
    error TooLate(uint time);

    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();

    //modifiers later
    modifier onlyBefore(uint time){
        if(block.timestamp < time)
            revert TooLate(time);
        _;
    }

    modifier onlyAfter(uint time){
        if(block.timestamp <= time)
            revert TooEarly(time);
        _;
    }

    constructor(uint biddingTime, uint revealTime, address payable beneficiaryAddress){
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd = biddingEnd + revealTime;
    }
    //blindedBid = keccak256(abi.encodePacked(value, fake, secret).
    //the sent ether is only refunded if the bid is correctly revealed

    function bid(bytes32 blindedBid) external payable onlyBefore(biddingEnd){
        bids[msg.sender].push(Bid({ blindedBid: blindedBid, deposit: msg.value}));
    }

    function reveal( uint[] calldata values, bool[] calldata fakes, bytes32[] calldata secrets) 
    external
    onlyAfter(biddingEnd)
    onlyBefore(revealEnd){
        //number of bids sent
        uint length = bids[msg.sender].length;
        require(values.length == length);
        require(fakes.length == length);
        require(secrets.length == length);

        uint refund;
        //create a loop through the bids sent by person currently interacting with contract
        for( uint i = 0; i< length; i++){
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) = (values[i], fakes[i], secrets[i]);

            if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value ,fake, secret))){
                continue;
            }
            refund += bidToCheck.deposit;
            if(!fake && bidToCheck.deposit >= value){
                if(placeBid(msg.sender, value))
                    refund -=value;
            }

            bidToCheck.blindedBid = bytes32(0);
        }

        payable(msg.sender).transfer(refund);
    }
    function auctionEnd()
        external
        onlyAfter(revealEnd)
    {
        if (ended) revert AuctionEndAlreadyCalled();
            emit AuctionEnded(highestBidder, highestBid);
            ended = true;
            beneficiary.transfer(highestBid);
        }
    // This is an "internal" function which means that it
    // can only be called from the contract itself (or from
    // derived contracts).
    function placeBid(address bidder, uint value) internal
    returns (bool success)
    {
        if (value <= highestBid) {
        return false;
    }
        if (highestBidder != address(0)) {
    // Refund the previously highest bidder.
        pendingReturns[highestBidder] += highestBid;
    }
        highestBid = value;
        highestBidder = bidder;
        return true;
}   

}