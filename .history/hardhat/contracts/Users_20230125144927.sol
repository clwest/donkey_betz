// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";

import "./Roles.sol";
import "./Mint.sol";

contract Users {
    // Starting ROLE for contract
    Roles private roles;

    // Contract for minting NFTs
    Mint private mint;

    using Counters for Counters.Counter;
    Counters.Counter private tokenIdsCounter;

    // Struct for creating the user
    struct User {
        address wallet;
        string name;
        string email;
        string username;
        string metadataHash;
        uint256 tokenId;
    }

    // Struct for blog

    struct Blog {
        string title;
        string content;
    }

    // mapping Struct to users wallet
    mapping(address => User) public users;
    mapping(address => bool) public minters;
    mapping(uint256 => address) public tokenOwner;

    // Blog mapping
    mapping(uint256 => Blog) public blogs;

    // Mappings to verifiy that the Username and Email are unique
    mapping(string => address) public usernameToAddress;
    mapping(string => address) public emailToAddress;

    mapping(address => uint256) public userTokenIds;

    // events for creating updating users, minting new use NFTs and Blog creation
    event UserCreated(address indexed user, string username);
    event UserUpdated(address indexed wallet);
    event TokenMinted(
        address indexed user,
        uint256 indexed tokenId,
        string metadataHash
    );
    event BlogMinted(address indexed user, uint256 tokenId);

    // Constructor for deploying Roles.sol and Mint.sol
    constructor(address _roles, address _mint) {
        require(_roles != address(0), "Roles address is not vailid");
        require(_mint != address(0), "Mint address is not vailid");
        roles = Roles(_roles);
        mint = Mint(_mint);
    }

    // requiring that the User have MINTER_ROLE to be aloud to mint NFTs
    modifier onlyMinter() {
        require(
            roles.hasRole(keccak256("MINTER_ROLE"), msg.sender),
            "Sender must have MINTER_ROLE to mint tokens"
        );
        _;
    }

    function createUser(
        address _wallet,
        string memory _name,
        string memory _email,
        string memory _username,
        string memory _metadataHash
    ) public onlyMinter {
        require(
            roles.hasRole(keccak256("MINTER_ROLE"), msg.sender),
            "Sender must have MINTER_ROLE to mint tokens"
        );
        require(
            validateEmail(_email) &&
                validateUsername(_username) &&
                validateAddress(_wallet)
        );

        // Get the next available token
        uint256 tokenId = tokenIdsCounter.current();
        mint.mint(_wallet, tokenId, _metadataHash);
        require(!_exists(tokenId), "Token already exists");
        // Mint the soul-bound NFT for the user

        // Create user and assign the tokenId,
        users[_wallet] = User(
            _wallet,
            _name,
            _email,
            _username,
            _metadataHash,
            tokenId
        );

        //Store email and username to address
        emailToAddress[_email] = _wallet;
        usernameToAddress[_username] = _wallet;
        // Grant Role as MINTER_ROLE
        roles.grantRole(_wallet, keccak256("MINTER_ROLE"));
        emit UserCreated(_wallet, _username);
    }

    function mintBlog(
        address _owner,
        string memory _title,
        string memory _content,
        string memory _metadataHash
    ) public {
        require(
            roles.hasRole(keccak256("MINTER_ROLE"), msg.sender),
            "Caller must be a minter"
        );

        // Get next available token ID
        uint256 tokenId = tokenIdsCounter.current();
        require(!_exists(tokenId), "Token already exists");

        // Mint the blog token
        mint.mint(_owner, tokenId, _metadataHash);
        blogs[tokenId] = Blog(_title, _content);
        tokenIdsCounter.increment();
        emit BlogMinted(_owner, tokenId);
    }

    function validateEmail(string memory _email) internal view returns (bool) {
        return emailToAddress[_email] == address(0);
    }

    function validateUsername(
        string memory _username
    ) internal view returns (bool) {
        return usernameToAddress[_username] == address(0);
    }

    function validateAddress(address _wallet) internal view returns (bool) {
        return users[_wallet].wallet == address(0);
    }

    function _exists(uint256 _tokenId) internal view returns (bool) {
        return tokenOwner[_tokenId] != address(0);
    }

    //
    function getTokenIdByUser(address _wallet) public view returns (uint256) {
        return userTokenIds[_wallet];
    }

    // Finds user by address
    function getUserByAddress(
        address _user
    ) public view returns (string memory, string memory) {
        return (users[_user].name, users[_user].username);
    }

    // Search for user by username
    function getUserByUsername(
        string memory _username
    ) public view returns (address, string memory) {
        User storage userByUsername = users[usernameToAddress[_username]];
        return (userByUsername.wallet, userByUsername.name);
    }

    function updateUserInfo(
        address _wallet,
        string memory _metadataHash,
        string memory _name,
        string memory _email,
        string memory _username,
        uint256 _newTokenId
    ) public onlyMinter {
        // Check that the new email is not already associated with another user

        // Check that the new metadataHash is not already associated with another user
        if (
            emailToAddress[_email] != address(0) &&
            emailToAddress[_email] != _wallet
        ) {
            revert("The email is already taken");
        }

        // Check that the new name is not already associated with another user
        if (users[_wallet].tokenId != 0) {
            revert("The tokenId is already associated with another user");
        }

        // Check that the new username is not already associated with another user
        if (
            usernameToAddress[_username] != address(0) &&
            usernameToAddress[_username] != _wallet
        ) {
            revert("The username is already taken");
        }

        // Update the email mapping
        if (emailToAddress[_email] == _wallet) {
            delete emailToAddress[_email];
        }
        emailToAddress[_email] = _wallet;

        // Update the username mapping
        if (usernameToAddress[_username] == _wallet) {
            delete usernameToAddress[_username];
        }
        usernameToAddress[_username] = _wallet;

        // Update the user struct
        User storage userToUpdate = users[_wallet];
        userToUpdate.name = _name;
        userToUpdate.email = _email;
        userToUpdate.username = _username;
        userToUpdate.metadataHash = _metadataHash;
        userToUpdate.tokenId = _newTokenId;

        // Emit an event to signal that the user's information has been updated
        emit UserUpdated(_wallet);
    }
}
