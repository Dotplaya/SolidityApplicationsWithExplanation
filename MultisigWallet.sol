// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// This is a Solidity file with a SPDX license identifier and a pragma directive specifying the version of the 
// Solidity compiler to be used.

contract MultiSigWallet {
    // This line defines a new contract named MultiSigWallet.

    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(address indexed owner, uint indexed txIndex,
            address indexed to, uint value, bytes data);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    // These lines define several events that will be emitted by the contract during different actions. They allow external 
    // entities to listen and react to these events.

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    // These lines declare state variables:
    // owners is an array that stores the addresses of the contract owners.
    // isOwner is a mapping that keeps track of whether an address is an owner or not.
    // numConfirmationsRequired is the number of confirmations required for a transaction to be executed.

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    // This defines a struct named Transaction, which represents a transaction to be executed. It includes information such as the recipient 
    // address (to), value (value), data (data), execution status (executed), and the number of confirmations received (numConfirmations)

    mapping(uint => mapping(address => bool)) public isConfirmed;

    // This mapping keeps track of which owners have confirmed each transaction. It maps the transaction index to a mapping of addresses to a boolean
    //  indicating whether the address has confirmed the transaction

    Transaction[] public transactions;

    // This is an array that holds all the transactions that have been submitted to the contract

    modifier OnlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    // This is a modifier named onlyOwner. It checks if the caller (the message sender) is an owner of the contract. If not, it reverts the transaction.

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    // This is a modifier named txExists. It checks if a transaction with the given _txIndex exists in the transactions array. If not, it reverts the transaction.

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    // This is a modifier named notExecuted. It checks if a transaction with the given _txIndex has already been executed. If it has, it reverts the transaction.

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    // This is a modifier named notConfirmed. It checks if the message sender has not already confirmed the transaction with the given _txIndex. If they have, it reverts 
    // the transaction.

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
         "invalid  number of required confirmations");
    

    //     This is the constructor of the contract. It initializes the contract with an array of owner addresses (_owners) and the number of confirmations required for
    //      a transaction (_numConfirmationsRequired).
    // The constructor checks that the _owners array is not empty and that the number of required confirmations is within a valid range.

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not uinque");
            isOwner[owner] = true;
            owners.push(owner);

        //    This loop iterates over the _owners array and performs the following actions:

        //     Checks that the owner address is not the null address (address(0)).
        //     Checks that the owner is not already marked as an owner.
        //     Sets the isOwner mapping to mark the owner as an owner.
        //     Adds the owner address to the owners array. 
        }

        numConfirmationsRequired = _numConfirmationsRequired;

        // This line sets the numConfirmationsRequired state variable to the value provided in the constructor.
        
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);

    }

    // This is a fallback function that allows the contract to receive Ether. It emits a Deposit event with the sender's address, the amount of Ether sent,
    //  and the updated balance of the contract.

    function submitTransaction(address _to, uint _value, bytes memory _data) public OnlyOwner {
        uint txIndex = transactions.length;
        transactions.push(Transaction({
            to : _to,
            value : _value,
            data: _data,
            executed : false,
            numConfirmations : 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);

    }

    //     This function allows an owner to submit a new transaction to be executed. It takes the recipient address _to, the
    //  value to be sent _value, and additional data _data as parameters.
    // It creates a new transaction struct with the provided values and adds it to the transactions array.
    // Finally, it emits a SubmitTransaction event to notify listeners about the new transaction.


    function confirmTransaction(uint _txIndex) public OnlyOwner txExists(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }    

    // This function allows an owner to confirm a transaction. It takes the transaction index _txIndex as a parameter.
    // It checks if the transaction exists, has not been executed, and has not already been confirmed by the caller.
    // If the checks pass, it increments the number of confirmations for the transaction, marks the caller's address
    //  as confirmed, and emits a ConfirmTransaction event.

    function executeTransaction(uint _txIndex) public OnlyOwner notExecuted(_txIndex) txExists(_txIndex)  {
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmations >= numConfirmationsRequired, "cannot execute tx");
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx Failed");

        emit ExecuteTransaction(msg.sender, _txIndex);

    }

    // This function allows an owner to execute a transaction. It takes the transaction index _txIndex as a parameter.
    // It checks if the transaction exists, has not been executed, and has received the required number of confirmations.
    // If the checks pass, it marks the transaction as executed, performs the external call to the recipient address with the 
    // specified value and data, and emits an ExecuteTransaction event

    function revokeConfirmation(uint _txIndex) public OnlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    // This function allows an owner to revoke their confirmation for a transaction. It takes the transaction index _txIndex as a parameter.
    // It checks if the transaction exists, has not been executed, and if the caller has already confirmed the transaction.
    // If the checks pass, it decrements the number of confirmations for the transaction, marks the caller's address as unconfirmed, and emits a
    // RevokeConfirmation event

    function getOwners() public view returns(address[] memory) {
        return owners;
    }

    // This function returns an array of all the owners of the contract.

    function getTransactionCount() public view returns(uint) {
        return transactions.length;
    }

    // This function returns the number of transactions that have been submitted.

    function getTransaction(uint _txIndex) public view returns(address to, uint value, bytes memory data, bool executed, uint numConfirmations) {
        Transaction storage transaction = transactions[_txIndex];
        return(transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numConfirmations);

    }

    // This function returns the details of a specific transaction at the given _txIndex. It returns the recipient address, value, data, execution status, and the number of
    //  confirmations received for that transaction.


}