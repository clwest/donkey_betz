// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Roles is AccessControl, Ownable {
    using SafeMath for uint256;

    // MINTER_ROLE is the entry point into the dapp with plans on adding others after MVP
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // ADMIN_ROLE will be transfered to the Mint contract so users can vote on increased
    // Roles based off of user partiaption.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(address => bool) public minters;
    mapping(bytes32 => mapping(address => bool)) public roles;
    // Stores the address of the owner of a specific token.
    mapping(address => mapping(uint256 => bool)) public tokenOfOwner;

    event RoleGranted(address user, bytes32 role);
    event RoleRevoked(address user, bytes32 role);
    event TokenMinted(
        address indexed user,
        uint256 indexed tokenId,
        string metadataHash
    );
    event MinterRoleRequested(address indexed user);

    constructor() {
        grantRole(msg.sender, ADMIN_ROLE);
    }

    function grantRole(
        address user,
        bytes32 role
    ) public onlyOwner onlyRole(ADMIN_ROLE) {
        require(role == MINTER_ROLE || role == ADMIN_ROLE, "Invalid role");
        _grantRole(role, user);

        if (role == MINTER_ROLE) {
            minters[user] = true;
        }
        emit RoleGranted(user, role);
    }

    function revokeRole(
        address user,
        bytes32 role
    ) public onlyOwner onlyRole(ADMIN_ROLE) {
        require(role == MINTER_ROLE || role == ADMIN_ROLE, "Invalid role");
        _revokeRole(role, user);

        if (role == MINTER_ROLE) {
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

    function requestMinterRole() public {
        emit MinterRoleRequested(msg.sender);
    }
}
