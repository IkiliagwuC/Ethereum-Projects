//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Purchase {
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State {
        Created,
        Locked,
        Release,
        Inactive
    }
    State public state; // = State.Created, State.Locked, State.Release, State.Inactive;

    modifier condition(bool condition_) {
        require(condition_);
        _;
    }

    error OnlyBuyer();
    error OnlySeller();
    error InvalidState();
    error ValueNotEven();

    modifier onlyBuyer() {
        if (msg.sender != buyer)
            //if the person calling the function is not buyer raise error
            revert OnlyBuyer();
        _;
    }

    modifier onlySeller() {
        if (msg.sender != seller)
            //if the person calling the function is not seller raise error
            revert OnlySeller();
        _;
    }

    modifier inState(State state_) {
        if (state != state_) revert InvalidState();
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        if ((2 * value) != msg.value) revert ValueNotEven();
    }

    function Abort() external onlySeller inState(State.Created) {
        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

    function confirmPurchase()
        external
        payable
        inState(State.Created)
        condition(msg.value == (2 * value))
    {
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) {
        emit ItemReceived();
        state = State.Release;
        buyer.transfer(value);
    }

    function refundSeller() external onlySeller inState(State.Release) {
        emit SellerRefunded(); //it is important to change the state first because the contractcalled using send can call in again here
        state = State.Inactive;
        seller.transfer(3 * value);
    }
}
