// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NeemOSVerify is ERC721, Ownable {
    uint256 private _nextTokenId;

    constructor() ERC721("NEEM-OS Identity", "NOID") Ownable(msg.sender) {}

    // The core SBT logic: Override transfer functions to disable them
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("SBT: Credentials are non-transferable");
        }
        return super._update(to, tokenId, auth);
    }

    // Function for an authorized entity (like a University) to issue a credential
    function issueCredential(address to) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }
}