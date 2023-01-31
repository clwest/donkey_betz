// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SoulboundNFT is ERC721, ERC721URIStorage {
    // Globals
    // The address of the contract owner
    address public owner;

    // TotalSupply: The total number of NFTs that will be minted
    uint256 public totalSupply;

    // IPSF hash for the Users metadata
    bytes32 public IPFS_hash;

    // Structs:
    // metadata: A struct that contains teh metadata URI and other metadata fields
    struct NFTMetadata {
        string name;
        string symbol;
        string uri;
        string extraData;
    }

    // User Struct
    struct User {
        address wallet; // Users Wallet address
        string username; // unique username
        uint256 SoulboundNFTId; // unique token Id of NFT
        bytes32 metadataHash; // holds NFTMetadata struct
        bytes32 ipfsHash;
        bool isBound; // Is NFT soul-bound to user == True;
    }

    struct PersonalAssistantData {
        string name;
        string description;
        string ipfsHash;
    }
    // Struct to keep track of the nonces of the users
    Counters public counter;

    // Mappings
    // Keeps track of registered users
    mapping(address => bool) public users;
    // Stores user-specific data such as profile  info and VPA
    mapping(address => User) public userData;
    // Mapping to store the URI of each NFT
    mapping(address => mapping(uint256 => bytes32)) public tokenURI;
    // metadata: A mapping of Token IDs to the metadata URI
    mapping(uint256 => NFTMetadata) public nftMetadata;
    // mapping of personal assistant data for each user
    mapping(address => PersonalAssistantData) personalAssistant;
    // Mapping to keep track of whether the personal assistant data exists for a given NFT or not
    mapping(uint256 => bool) public personalAssistantDataExists;
    // Mapping to keep track of the owner of each soul-bound NFT
    mapping(uint256 => address) public nftOwner;

    // Events:
    // Transer: Overridden
    event UserCreated(address indexed user, string username);

    // Approval: Triggered when an adddress is approved to spend NFTs on behalf of another address
    // ApprovalForAll: Triggered when an address is approved to spend NFTs on behalf of another address
    // for all its NFTs
    // Mint: Triggered when a new NFT it minted

    // Modifiers:
    // onlyOwner: Restricts a function to only be called by the owner of the NFT
    // only Approved: Restricts a funtion to only be called by the approved spender of the NFT
    // whenNotPaused: Restricts a funtion to only be called when the contract is not paused

    // Functions:

    // Mint() To mint new NFT to specific address and assign it a unique tokenID
    function mint(address _to, bytes memory _extraData) public {
        // Ensure that the caller is the minter
        require(msg.sender == minter, "Only the minter can mint new tokens.");
        // Create a new token ID
        uint256 newTokenId = totalSupply;
        // Increment the total supply
        totalSupply++;
        // Set the owner of the new token
        owners[newTokenId] = _to;
        // Set the extra data for the new token
        extraData[newTokenId] = _extraData;
        // Emit the Transfer event
        emit Transfer(address(0), _to, newTokenId);
    }

    function modify(
        uint256 _tokenId,
        string memory _name,
        string memory _description,
        string memory _image,
        string[] memory _tags,
        string memory _uri
    ) public {
        // Modify the NFT's metadata
        metadata[_tokenId].name = _name;
        metadata[_tokenId].description = _description;
        metadata[_tokenId].image = _image;
        metadata[_tokenId].tags = _tags;
        metadata[_tokenId].uri = _uri;
    }

    // ownerOF(): To get the address that currently owns a specific tokenId

    // totalSupply(): To get the total number of NFTs that have been minted

    // balanceOf(): to get the number of NFTs an address owns

    // approve(): To approve another address to spend NFTs on behalf of the owner

    // setApprovalForAll(): To approve another address to spend all NFTs on behalf of the owner

    // Transfer(): To transfer NFTs from one address to another (ex: soul-bound)

    // getUserName(): To get the user name associated with the specific address

    // setUserName(): To set the username associated with the specific address

    // getMetadata(): To get the metadata URI associated with a specific tokenId

    // setMetadata(): To set the metadata URI associated with a specific tokenId

    // tokenURI(): returns the URI of the token, which can be used to fetch the metadata
}
