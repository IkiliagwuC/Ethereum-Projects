//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract StakingRewards{
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    address public owner;
    uint public duration;
    uint public finishAt;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;

    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;

    //track totalSupply of the Staking token
    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier updateReward(address _account)  {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    //set the reward for the duration
    function setRewardsDuration(uint _duration) external onlyOwner{
        require(finishAt < block.timestamp, "reward duration not finished"); //cannot set rewardDuration during a reward period
        duration = _duration;
    }

    //to send rewards token into the contract and set reward rate
    function notifyRewardAmount(uint _amount) external onlyOwner updateReward(address(0)) {
        if(block.timestamp > finishAt){ //rewardDuration is expired or has not started
            rewardRate = _amount/duration;
        } else { //ongoing rewards
            uint remainingRewards = rewardRate * (finishAt - block.timestamp); //(finishAt - block.timestamp) -> time left till rewards end
            rewardRate = (remainingRewards + _amount)/duration;
        }

        require(rewardRate > 0, "reward rate  = 0");
        require(rewardRate * duration <= rewardsToken.balanceOf(address(this)),"rewards amount > balance");

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function stake( uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount > 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount; //staked by msg.sender
        totalSupply += _amount;//staked in contract;
    }

    function withdraw(uint _amount) external updateReward(msg.sender){
        require(_amount > 0, "amount = 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer( msg.sender, _amount);

    }

    //returns the timestamp when the last reward was applied
    function lastTimeRewardApplicable() public view returns(uint) {
        return _min(block.timestamp, finishAt);
    }

    function rewardPerToken() public view returns(uint){
        if (totalSupply == 0){
            return rewardPerTokenStored; 
        } 
        return rewardPerTokenStored + rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18 /totalSupply;
    }

    function earned( address _account) public view returns(uint){
        return (balanceOf[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18 + rewards[_account];
    }

    function getReward() external updateReward(msg.sender){
        uint reward = rewards[msg.sender];
        if(reward > 0){
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }

    }

    function _min(uint x, uint y) internal pure returns(uint) {
        return x <= y ? x : y;
    }
}