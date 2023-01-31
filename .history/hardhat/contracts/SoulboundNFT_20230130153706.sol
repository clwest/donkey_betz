// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Roles.sol";

contract SoulboundNFT is ERC721, ERC721URIStorage {
    Roles private roles;
    // Globals
    // The address of the contract owner
    address public owner;

    // TotalSupply: The total number of NFTs that will be minted
    uint256 public totalSupply;

    // IPSF hash for the Users metadata
    bytes32 public IPFS_hash;

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
    mapping(address => uint256) public tokensOwned;
    // mapping to track noncues for each user
    mapping(address => UserNonce) public userNonces;
    //
    mapping(address => bool) public mintedNFT;

    // Structs:

    // User Struct
    struct User {
        address wallet; // Users Wallet address
        string username; // unique username
        string email; // unique email
        uint256 SoulboundNFTId; // unique token Id of NFT
        uint256 personalAssistant; // holds NFTMetadata struct
        uint256 nftMetadata; // mapping to the NFT Metadata struct
        bytes32 ipfsHash;
        bool isBound; // Is NFT soul-bound to user == True;
        uint256 userNonces; //
    }

    // metadata: A struct that contains teh metadata URI and other metadata fields
    struct NFTMetadata {
        // By using bytes32 instead of string
        // we can make sure that the NFT title does not change
        bytes32 name;
        bytes32 symbol;
        bytes32 ipfsHash;
        bytes32 extraData;
    }

    // PersonalAssistantData from OpenAi API
    struct PersonalAssistantData {
        string name;
        string description;
        bytes32 ipfsHash;
        uint256 tokenId;
    }
    // Struct to keep track of the nonces of the users
    struct UserNonce {
        address user;
        uint256 nonce;
    }

    // Events:
    // UserCreation
    event UserCreated(address indexed user, string username);
    // NFTMinted
    event NFTMinted(address indexed user, uint256 indexed nftId);
    // Personal assistant events
    event PersonalAssistantMinted(
        address indexed user,
        uint256 indexed personalAssistantId
    );
    event PersonalAssistantBound(
        address indexed user,
        uint256 indexed personalAssistantId
    );

    // Approval: Triggered when an adddress is approved to spend NFTs on behalf of another address
    event Approval(
        address indexed tokenOwner,
        address indexed approved,
        uint256 indexed tokenId
    );

    // ApprovalForAll: Triggered when an address is approved to spend NFTs on behalf of another address
    // for all its NFTs
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Modifiers:
    // whenNotPaused: Restricts a funtion to only be called when the contract is not paused    modifier onlyWhenNotPaused {
    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    modifier onlyOwnerAndMinter() {
        require(
            isOwner() || roles.isMinter(msg.sender),
            "Only owner or minter role can mint NFTs"
        );
        _;
    }

    // Constructor that takes the address of the deployed Roles contract as an argument
    constructor(address _roles) public ERC721("Donkey Betz", "DONK") {
        // Assign the passed address to the private variable
        roles = Roles(_roles);
        owner = msg.sender;
    }

    // Functions:
    // ownerOF(): To get the address that currently owns a specific tokenId
    function ownerOf(uint256 _tokenId) public view returns (address) {
        return _tokenOwner[_tokenId];
    }

    function _totalSupply() public view returns (uint256) {
        require(!mintedNFT[msg.sender], "You have already minted an NFT");
        mintedNFT[msg.sender] = true;
        return _totalSupply;
    }

    function mintNFT(
        address _to,
        uint256 _tokenId
    ) public onlyOwnerAndMinter onlyWhenNotPaused {
        require(_to != address(0), "Cannot mint to address 0x0");
        require(isMinter(), "Sender must have minter role");
        require(tokenOfOwner[msg.sender] == 0, "Address already owns an NFT");
        require(_totalSupply < maxSupply, "max supply reached");

        _mint(_to, _tokenId);
        this._totalSupply++;
        emit Transfer(address(0), _to, _tokenId);
    }

    function mintSoulboundNFT(
        address _to,
        uint256 _tokenId
    ) public onlyOwnerAndMinter onlyWhenNotPaused {
        // Check that the msg.sender is the ADMIN_ROLE
        require(roles.hasRole(msg.sender, ADMIN_ROLE));
        // Check that the token ID is not already taken
        require(_tokenIdToOwner[_tokenId] == address(0));
        // Assign the token ID to the given address
        _tokenIdToOwner[_tokenId] = _to;
        // Assign the MINTER_ROLE to the given address
        roles.grantRole(_to, MINTER_ROLE);
        // Check that the owner does not already own an NFT
        require(tokenOfOwner[_to] == 0, "User already owns a unique NFT");
        // Emit the Transfer event
        emit Transfer(address(0), _to, _tokenId);
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

    // track the Nonce
    // Ensure that each transactoin from a user's address is unique.
    function incrementNonce(address _user) public {
        require(
            msg.sender == _user,
            "Only the user can increment their nonce."
        );
        userData[_user].nonce++;
    }

    // Modifier to make NFT Soulbound and non-transferable
    modifier canNotTransfer(uint256 _tokenId) {
        require(
            tokenOfAddressOwner[_tokenId] == msg.sender,
            "This token is SOUL BOUND."
        );
        _;
    }

    // balanceOf(): to get the number of NFTs an address owns should return 1 or 0 only
    function balanceOf(address _owner) public view returns (uint256) {
        // check if the provided address has already minted an NFT
        return ownedTokens[_owner] == 0 ? 0 : 1;
    }

    // function To set the username associated with the specific address

    // getMetadata(): To get the metadata URI associated with a specific tokenId

    // setMetadata(): To set the metadata URI associated with a specific tokenId

    // tokenURI(): returns the URI of the token, which can be used to fetch the metadata
}
