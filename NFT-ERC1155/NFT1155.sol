// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract NFT1155 is ERC1155 {
    uint256 public constant koala = 1;
    uint256 public constant pooh = 2;
    uint256 public constant panda = 3;

    constructor() ERC1155("https://ipfs.io/ipfs/bafybeihj2yqpyfghlsplqalfpzuklt5px4dftdqucestf6whzrwsc2zh7y/{id}.json") { 
        _mint(msg.sender, koala, 1, "");
        _mint(msg.sender, pooh, 1, "");
        _mint(msg.sender, panda, 1, "");
    }

    function uri(uint256 _tokenid) override public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/bafybeihj2yqpyfghlsplqalfpzuklt5px4dftdqucestf6whzrwsc2zh7y/",
                Strings.toString(_tokenid),".json"
            )
        );
    }
}