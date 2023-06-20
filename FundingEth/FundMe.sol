//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    uint256 public minimumUsd = 50 * 1e18;

    //array for storing senders addresses
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        //want to be able to set a miniimym fund amount in usd
        //how do we send eth to this contract?
        require(getConversionRate(msg.value) >= minimumUsd, "not enough ether sent");
        //msg.value has 18 decimal places (wei)

        //push senders address to array
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    //get price of etherum of blockchain you're working with in terms of Usd
    function getPrice() public view returns(uint256){
        //ABI ( does not necessarily include all the logic), compiling the interface returns the ABI of a contract
        //Address

        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price *1e10);
        //Price of eth in terms of USDs
        //172700000000
    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    //

    //function withdraw
    //8 decimals from the oracle price feed

}