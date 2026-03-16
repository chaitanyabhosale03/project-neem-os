// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NeemOSNexus is ERC1155, Ownable {
    // Define game asset IDs
    uint256 public constant DAGGER_OF_TIME = 0; // Unique Legendary
    uint256 public constant PLASMA_RIFLE = 1;   // Epic Weapon
    uint256 public constant HEALTH_PACK = 2;    // Stackable Consumable

    constructor() ERC1155("ipfs://your-gaming-metadata-cid/{id}.json") Ownable(msg.sender) {}

    // Mint a single unique asset (like a legendary weapon)
    function mintLegendary(address account, uint256 id) public onlyOwner {
        require(id == DAGGER_OF_TIME, "Only for unique items");
        _mint(account, id, 1, "");
    }

    // Mint stackable items (like 100 health packs)
    function mintConsumables(address account, uint256 id, uint256 amount) public {
        require(id != DAGGER_OF_TIME, "Cannot batch mint legendaries");
        _mint(account, id, amount, "");
    }
}