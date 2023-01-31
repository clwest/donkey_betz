// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract UserSignup {
    // Struct for creating the user
    struct User {
        address wallet;
        string name;
        string email;
        string username;
        string metadataHash;
    }

    // mapping Struct to users wallet
    mapping(address => User) public users;

    // Mappings to verifiy that the Username and Email are unique
    mapping(string => address) public usernameToAddress;
    mapping(string => address) public emailToAddress;

    // events for creating updating users, minting new use NFTs and Blog creation
    event UserCreated(address indexed user, string username);

    constructor() {}

    function createUser(
        address _wallet,
        string memory _name,
        string memory _email,
        string memory _username,
        string memory _metadataHash
    ) public {
        // Create user and assign the tokenId,
        users[_wallet] = User(_wallet, _name, _email, _username, _metadataHash);

        //Store email and username to address
        emailToAddress[_email] = _wallet;
        usernameToAddress[_username] = _wallet;
        emit UserCreated(_wallet, _username);
    }

    function validateUnique(
        string memory _email,
        string memory _username,
        address _wallet
    ) internal view returns (bool) {
        return
            emailToAddress[_email] == address(0) &&
            usernameToAddress[_username] == address(0) &&
            users[_wallet].wallet == address(0);
    }
}
