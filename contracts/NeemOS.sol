// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24; // <-- Update this line

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NeemOS is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    constructor() ERC721("NEEM-OS Fashion", "NEEM") Ownable(msg.sender) {}

    // Mint a new fashion NFT
    function mintFashionItem(string memory uri) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }
}