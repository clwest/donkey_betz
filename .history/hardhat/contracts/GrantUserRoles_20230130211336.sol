// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract GrantUserRoles is AccessControl {
    // Roles for the project that the users can access

    enum Roles {
        // Entry level role that all creators that sign up receive
        MINTER_ROLE,
        // Given to Users that create loads of content for the project
        CREATOR_ROLE,
        // Visitors to the project that are not creators
        VIEWER_ROLE,
        // This person is someone that connects projects together. They may not Create content NFTS
        // But they take place in creating content.
        TRADER_ROLE,
        // Admin controls all roles,will be given to
        // the contract with voting parameters to allow users to vote on role increasment
        ADMIN_ROLE
    }
    // Mapping of addresses with the MINTER_ROLE
    mapping(address => bool) public minters;
    // Mapping to store the roles of Users
    mapping(bytes32 => mapping(address => bool)) public roles;
    // Mapping bytes32 to bool

    // Mappings to tokens the Users owns
    mapping(address => mapping(uint256 => bool)) public tokenOfOwner;
    mapping(Roles => bytes32) public roleBytes;

    event RoleGranted(address user, bytes32 role);
    event RoleRevoked(address user, bytes32 role);
    event TokenMinted(
        address indexed user,
        uint256 indexed tokenId,
        string metadataHash
    );
    event NewRoleRequestedOrSuggested(
        address indexed user,
        address indexed suggestedBy
    );

    constructor() {
        roles[Roles.MINTER_ROLE] = keccak256("MINTER_ROLE");
        roleBytes[Roles.ADMIN_ROLE] = true;
    }

    function grantRole(Roles role, address user) public {
        require(
            role == Roles.MINTER_ROLE || role == Roles.ADMIN_ROLE,
            "Invalid role"
        );
        _grantRole(roleBytes[role], user);
        if (role == Roles.MINTER_ROLE) {
            minters[user] = true;
        }
        emit RoleGranted(user, roleBytes[role]);
    }

    function revokeRole(address user, bytes32 role) public {
        require(
            role == roles.MINTER_ROLE || role == roles.ADMIN_ROLE,
            "Invalid role"
        );
        _revokeRole(role, user);

        if (role == roles.MINTER_ROLE) {
            minters[user] = false;
        }
        emit RoleRevoked(user, role);
    }

    function hasRole(
        bytes32 role,
        address user
    ) public view override returns (bool) {
        return roles[role][user];
    }

    function requestOrSuggestNewRole(address _user) public {
        emit NewRoleRequestedOrSuggested(_user, msg.sender);
    }
}
