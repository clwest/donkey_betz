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
    
    // Name: The name of the NFT
    // Symbol: The symbol of the NFT
    // TotalSupply: The total number of NFTs that will be minted
    // balances: A mapping of addresses to the number of NFTs they own
    // ownerOf: A mapping of token IDs to the address of the owner
    // approved: A mapping of Token IDs
}
