// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// This is a Solidity file with a SPDX license identifier and a pragma directive
//  specifying the version of the Solidity compiler to be used

contract MerkleProof {
    // This line defines a contract named MerkleProof

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf, uint index) public pure returns(bool) {
    // This is a function named verify that takes in four parameters:

    // proof: an array of bytes32 values representing the Merkle proof path.
    // root: a bytes32 value representing the Merkle root.
    // leaf: a bytes32 value representing the leaf node for which the proof is being verified.
    // index: an uint value representing the position of the leaf node in the Merkle tree.
        bytes32 hash = leaf;
        // This line initializes a bytes32 variable named hash with the value of leaf

        for (uint i = 0;i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            // This is a loop that iterates through each element in the proof array.
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            }
            else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }
                // This block conditionally calculates the hash value based on whether the index is even or odd.
                // If the index is even, it calculates the hash by concatenating hash and proofElement.
                // If the index is odd, it calculates the hash by concatenating proofElement and hash.

            index = index / 2;

            // his line updates the index by dividing it by 2 in each iteration of the loop to traverse up the Merkle tree

        }

        return hash == root;

        // This line returns a boolean value indicating whether the calculated hash matches the provided root value
    }
}

contract TestMerkleProof is MerkleProof {
    // This line defines a new contract named TestMerkleProof that inherits from the MerkleProof contract.

    bytes32[] public hashes;
    // This declares a public array of bytes32 values named hashes.

    constructor() {
        string[4] memory transactions = [
            "alice -> bob",
            "bob -> dave",
            "carol -> alice",
            "dave -> bob"
        ];
        // This is the constructor of the TestMerkleProof contract. It initializes the contract and defines an array of strings named transactions 
        // with 4 transaction messages.
        for(uint i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
                // This loop iterates through each transaction message in the transactions array.
                // It calculates the keccak256 hash of each transaction message using keccak256
                // (abi.encodePacked(transactions[i])).
                // The resulting hash is then pushed into the hashes array.
        }
        uint n = transactions.length;
        uint offset = 0;

        while (n > 0){
            for (uint i = 0; i < n -1; i += 2) {
                hashes.push(keccak256(abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])));
            }
            offset += n;
            n = n / 2;
        }

        // This section of code calculates the Merkle tree root hash based on the transaction hashes.
        // It uses a while loop to iterate until n becomes zero.
        // In each iteration, it performs a pairwise concatenation of adjacent hashes in the hashes array.
        // The resulting hash is then pushed into the hashes array for the next iteration.
        // The offset variable keeps track of the starting index of each iteration.
        // The n value is halved in each iteration to reduce the number of hashes being processed until it reaches zero
    }

    function getRoot() public view returns(bytes32) {
        return hashes[hashes.length -1];
    }

    // This function returns the last element of the hashes array, which represents the Merkle tree root hash.

}