// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SoulboundNFT is ERC721 {
    // Globals
    // The address of the contract owner
    address public owner;

    // TotalSupply: The total number of NFTs that will be minted
    uint256 public totalSupply;

    // Name of NFT
    bytes32 public name;

    // Symbol of NFT
    bytes32 public symbol;

    // Struct
    struct User {
    address wallet; // Users Wallet address
    string username; // unique username
    uint256 SoulboundNFTId; // unique token Id of NFT
    bytes32 metadataHash; // holds IPFS hash of the user's metadata
    bool isBound; // Is NFT soul-bound to user == True;
}

    
    // Mappings
    // Keeps track of registered users
    mapping (address => bool) public users;
    // Stores user-specific data such as profile  info and VPA
    mapping (address => User) public userData;
    // Mapping to store the URI of each NFT
    mapping (address => mapping (uint256 => bytes32)) public tokenURI;
    // balances: A mapping of addresses to the number of NFTs they own
    // ownerOf: A mapping of token IDs to the address of the owner
    // approved: A mapping of Token IDs to the address of the approved spender
    // metadata: A mapping of Token IDs to the metadata URI
    // addressToUsername: A mapping of address to the user that is associated with teh address

    // Structs:
    // metadata: A struct that contains teh metadata URI and other metadata fields

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

