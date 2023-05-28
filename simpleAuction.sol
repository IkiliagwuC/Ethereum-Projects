// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
contract SimpleAuction {
    address payable public beneficiary;
    uint public auctionEndTime;

    //current state of the auction, address of the highest bidder and amount of the highest bid
    address public highestBidder;
    uint public highestBid;

    //allow withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    //set this to true after bidding is done to disallow any change
    bool ended;

    //events that will be emitted on changes
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    //natspec comments: will be shown when the user is asked
    //to confirm a transaction or when an error is shown

    ///the auction has already ended.
    error AuctionAlreadyEnded();
    ///there is already a higher or equal bid.
    error BidNotHighEnough(uint highestBid);
    ///auction has not ended yet;
    error AuctionNotYetEnded();
    ///the function auctionEnd has already been called;
    error AuctionEndAlreadyCalled();

    ///create a simple auction with biddingTime
    ///seconds bidding time on behalf of the beneficiary address beneficiary address
    constructor(
        uint biddingTime,
        address payable beneficiaryAddress
    ){
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }

    function bid() external payable {
        //do some checks
        if(block.timestamp > auctionEndTime){
            revert AuctionAlreadyEnded();
        }
        if(msg.value <= highestBid){
            revert BidNotHighEnough(highestBid);
        }

        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);

    }

    //withdraw a bid that was overbid
    function withdraw() external returns(bool) {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0) {
            pendingReturns[msg.sender] = 0;
        
        if (!payable(msg.sender).send(amount)) {
            pendingReturns[msg.sender] = amount;
            return false;
            }
        }
        return true;
    }
    //end the auction and send the highest bid to the beneficiary
    function auctionEnd() external {
        if(block.timestamp < auctionEndTime)
            revert AuctionNotYetEnded();
        if (ended)
            revert AuctionEndAlreadyCalled();
        
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}
