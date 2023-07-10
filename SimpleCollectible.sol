//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title ERC-721 NFT
//old tutorial 
//import openZeppelin docs
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SimpleCollectible is ERC721 {
    uint public tokenCounter;


    /**
        * @notice Collectible constructor
        * @dev constructor inherits from the ERC721 contract
        * @param _name is the name of the ERC721 token
        * @param _symbol is the symbol of the ERC721 token
    */
    constructor() ERC721 ("Smiling Dogs NFT", "SDN"){
        tokenCounter = 0;
    }

    /** 
        *  @notice Create collectible Contract
        * @dev this function creates a new NFT(Collectible)
        * @param tokenURI takes nft location, api call ipfs
        * @param newItemId Id of the new NFT created
        * @param tokenCounter used to increment the Id of minted tokens
    */
    function createCollectible(string memory tokenURI) public returns(uint256){
        uint newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId); //person calling function is owner
        _setTokenURI(newItemId, tokenURI);
        tokenCounter = tokenCounter + 1;
        return newItemId;
    }
}

//Create NFT from openzeppelin (New Implementation)
// contracts/GameItem.sol
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GameItem is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("GameItem", "ITM") {}

    function awardItem(address player, string memory tokenURI)
        public
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }
}