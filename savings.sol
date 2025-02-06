// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SavingsContract {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public fixedDeposits;
    mapping(address => uint256) public fixedDepositRelease;
    
    event Deposited(address indexed user, uint256 amount);
    event FixedDeposit(address indexed user, uint256 amount, uint256 releaseTime);
    event Withdrawn(address indexed user, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    function fixedDeposit(uint256 timeLock) external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        require(timeLock > block.timestamp, "Invalid time lock");
        fixedDeposits[msg.sender] += msg.value;
        fixedDepositRelease[msg.sender] = timeLock;
        emit FixedDeposit(msg.sender, msg.value, timeLock);
    }
    
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }
    
    function withdrawFixedDeposit() external {
        require(block.timestamp >= fixedDepositRelease[msg.sender], "Deposit is still locked");
        require(fixedDeposits[msg.sender] > 0, "No fixed deposit available");
        uint256 amount = fixedDeposits[msg.sender];
        fixedDeposits[msg.sender] = 0;
        fixedDepositRelease[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }
    
    function withdrawContractBalance(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(owner).transfer(amount);
    }

    function getBalances(address user) external view returns (uint256[] memory) {
        uint256[] memory userBalances = new uint256[](2);
        userBalances[0] = balances[user];
        userBalances[1] = fixedDeposits[user];
        return userBalances;
    }
    
    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
}
