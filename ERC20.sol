// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


    // This is a Solidity file with a SPDX license identifier and a pragma directive specifying the version of 
    // the Solidity compiler to be used.

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// This is an interface definition for the ERC20 token standard. It specifies the required functions and
//  events that an ERC20 token contract must implement

contract ERC20 is IERC20 {
    
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Solidity by example"; 
    string public symbol = "SOLBYEX";
    uint8 public decimals = 18;

    // This line defines a contract named ERC20 that implements the IERC20 interface. 
    // It represents an ERC20 token contract.
    // The contract includes state variables totalSupply, balanceOf, and allowance which 
    // keep track of the total supply of tokens, balances of token holders, and approved token
    //  transfer allowances.
    // It also includes variables name, symbol, and decimals which represent the name, symbol, 
    // and decimal places of the token, respectively.

    function transfer(address recipient, uint amount) external returns(bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // This function allows a token holder to transfer a specified amount of tokens to a recipient.
    // It updates the balances of the sender and recipient accordingly and emits a Transfer event to notify listeners
    // about the token transfer

    function approve(address spender, uint amount) external returns(bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;

    }

    // This function allows a token holder to approve a spender to transfer a certain amount of tokens on their behalf.
    // It updates the allowance mapping to store the approved amount and emits an Approval event to notify listeners about
    //  the approval.

    function transferFrom(address sender, address recipient, uint amount) external returns(bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // This function allows a spender to transfer tokens from a specified sender to a recipient, given that the sender
    // has approved the spender for a sufficient allowance.
    // It updates the allowance and balances accordingly and emits a Transfer event to notify listeners about the token transfer.

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }


    // This function allows the contract owner (msg.sender) to mint (create) new tokens.
    // It increases the balance of the contract owner and the total supply of tokens.
    // It emits a Transfer event to notify listeners about the minted tokens.

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    //     This function allows a token holder to burn (destroy) a specified amount of their tokens.
    // It decreases the balance of the token holder and the total supply of tokens.
    // It emits a Transfer event to notify listeners about the burned tokens.

}
