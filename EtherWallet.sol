// SPDX-License-Identifier: MIT
// This line specifies the license under which the code is released. In this case,
//  it is the MIT license.
pragma solidity ^0.8.17;
// This line specifies the version of the Solidity programming language that the contract
//  is written in. In this case, it requires a version equal to or greater than 0.8.17

contract EhterWallet {
    // This line declares the start of the contract named "EtherWallet"

    address payable public owner;
    // This line declares a public state variable called "owner" of type address payable.
    //  The payable modifier allows the address to receive Ether.

    constructor () {
        owner = payable(msg.sender);
    }
    // This is the constructor function that gets executed when the contract is deployed.
    //  It assigns the address that deploys the contract (msg.sender) to the "owner" 
    //  variable

    receive() external payable{}
    // This is a fallback function that allows the contract to receive Ether.
    //  It is marked as external to indicate that it can be called from outside 
    //  the contract, and payable to allow it to receive Ether.

    function withDraw(uint _amount) external {
        require(msg.sender == owner, "only owner can call this Function.");
        payable(msg.sender).transfer(_amount);
    } 

    // This function allows the owner of the contract to withdraw a specified amount of
    //  Ether. It requires that the caller is the owner (the one who deployed the contract).
    //   If the requirement is met, it transfers the specified amount of Ether from the
    //    contract to the owner's address.

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }

    // This function allows anyone to view the balance of the contract,
    //  which represents the amount of Ether it currently holds. It is marked as
    //   view because it doesn't modify the contract's state, and it returns the
    //    balance as a uint (unsigned integer).
}