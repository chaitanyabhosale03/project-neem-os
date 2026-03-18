// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/**
 * @title NeemOSNexusV2
 * @dev Advanced gaming asset management with crafting, battle encounters, and item evolution
 * Features: Burn & Mint Crafting, Rarity System, Marketplace Support
 */
contract NeemOSNexusV2 is
  ERC1155Upgradeable,
  OwnableUpgradeable,
  AccessControlUpgradeable,
  UUPSUpgradeable
{
  // Role definitions
  bytes32 public constant GAME_MASTER_ROLE = keccak256("GAME_MASTER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  // Item constants with rarity levels
  uint256 public constant LEGENDARY_SWORD  = 1;
  uint256 public constant PLASMA_RIFLE     = 2;
  uint256 public constant HEALTH_PACK      = 3;
  uint256 public constant MANA_POTION      = 4;
  uint256 public constant DRAGON_ARMOR     = 5;
  uint256 public constant RARE_GEM         = 6;

  // Item rarity enum
  enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

  // Crafting recipe struct
  struct CraftingRecipe {
    uint256[] inputIds;
    uint256[] inputAmounts;
    uint256 outputId;
    uint256 outputAmount;
    uint256 craftingTimeSeconds;
    bool active;
  }

  // Item metadata struct
  struct ItemMetadata {
    string name;
    Rarity rarity;
    uint256 maxSupply;
    uint256 currentSupply;
    bool soulbound;
  }

  // Player inventory tracking
  struct InventorySlot {
    uint256 itemId;
    uint256 equippedAt;
    bool isEquipped;
  }

  // Storage mappings
  mapping(uint256 => CraftingRecipe) public recipes;
  mapping(uint256 => ItemMetadata) public itemMetadata;
  mapping(address => InventorySlot[]) public playerInventory;
  mapping(address => uint256) public lastCraftingTime;
  mapping(uint256 => uint256) public recipeCount;

  uint256 public recipeCountTotal;
  string public gameVersion;

  // Events
  event RecipeAdded(uint256 indexed recipeId, uint256 indexed outputId, string name);
  event ItemsCrafted(address indexed player, uint256 indexed recipeId, uint256 outputAmount, uint256 timestamp);
  event ItemMetadataSet(uint256 indexed itemId, string name, uint8 rarity);
  event ItemEquipped(address indexed player, uint256 indexed itemId, uint256 slotIndex);
  event ItemUnequipped(address indexed player, uint256 indexed itemId);
  event RarityUpgraded(address indexed player, uint256 indexed itemId, uint8 newRarity);

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  /**
   * @dev Initialize the contract with base configuration
   * @param uri_ Base URI for token metadata
   */
  function initialize(string memory uri_) public initializer {
    __ERC1155_init(uri_);
    __Ownable_init(msg.sender);
    __AccessControl_init();
    __UUPSUpgradeable_init();
    
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(GAME_MASTER_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
    
    gameVersion = "2.0.0";
  }

  /**
   * @dev Add a new crafting recipe
   * @param inputIds Array of input item IDs
   * @param inputAmounts Array of input amounts
   * @param outputId Output item ID
   * @param outputAmount Output amount
   * @param craftingTimeSeconds Time required to craft
   */
  function addRecipe(
    uint256[] calldata inputIds,
    uint256[] calldata inputAmounts,
    uint256 outputId,
    uint256 outputAmount,
    uint256 craftingTimeSeconds
  ) external onlyRole(GAME_MASTER_ROLE) {
    require(inputIds.length == inputAmounts.length, "Mismatched arrays");
    require(inputIds.length > 0, "Empty recipe");
    require(outputAmount > 0, "Invalid output");

    recipes[recipeCountTotal] = CraftingRecipe({
      inputIds: inputIds,
      inputAmounts: inputAmounts,
      outputId: outputId,
      outputAmount: outputAmount,
      craftingTimeSeconds: craftingTimeSeconds,
      active: true
    });

    emit RecipeAdded(recipeCountTotal, outputId, itemMetadata[outputId].name);
    recipeCountTotal++;
  }

  /**
   * @dev Craft items by burning inputs and minting outputs
   * @param recipeId Recipe ID to craft
   */
  function craft(uint256 recipeId) external {
    require(recipeId < recipeCountTotal, "Invalid recipe");
    CraftingRecipe storage r = recipes[recipeId];
    require(r.active, "Recipe inactive");

    // Check crafting cooldown
    uint256 timeSinceLast = block.timestamp - lastCraftingTime[msg.sender];
    require(timeSinceLast >= r.craftingTimeSeconds, "Crafting cooldown active");

    // Burn all inputs atomically
    _burnBatch(msg.sender, r.inputIds, r.inputAmounts);

    // Mint the new item
    _mint(msg.sender, r.outputId, r.outputAmount, "");

    lastCraftingTime[msg.sender] = block.timestamp;

    emit ItemsCrafted(msg.sender, recipeId, r.outputAmount, block.timestamp);
  }

  /**
   * @dev Set metadata for an item
   * @param itemId Item ID
   * @param name Item name
   * @param rarity Item rarity level
   * @param maxSupply Maximum supply (0 for unlimited)
   * @param soulbound Whether item is soulbound
   */
  function setItemMetadata(
    uint256 itemId,
    string calldata name,
    Rarity rarity,
    uint256 maxSupply,
    bool soulbound
  ) external onlyRole(GAME_MASTER_ROLE) {
    itemMetadata[itemId] = ItemMetadata({
      name: name,
      rarity: rarity,
      maxSupply: maxSupply,
      currentSupply: 0,
      soulbound: soulbound
    });

    emit ItemMetadataSet(itemId, name, uint8(rarity));
  }

  /**
   * @dev Mint items from game rewards or admin minting
   * @param to Recipient address
   * @param id Item ID
   * @param amount Amount to mint
   */
  function mintGameItem(
    address to,
    uint256 id,
    uint256 amount
  ) external onlyRole(MINTER_ROLE) {
    ItemMetadata storage metadata = itemMetadata[id];
    if (metadata.maxSupply > 0) {
      require(metadata.currentSupply + amount <= metadata.maxSupply, "Max supply exceeded");
      metadata.currentSupply += amount;
    }
    _mint(to, id, amount, "");
  }

  /**
   * @dev Equip an item in player inventory
   * @param itemId Item ID to equip
   */
  function equipItem(uint256 itemId) external {
    require(balanceOf(msg.sender, itemId) > 0, "Item not owned");

    InventorySlot[] storage inventory = playerInventory[msg.sender];
    inventory.push(
      InventorySlot({itemId: itemId, equippedAt: block.timestamp, isEquipped: true})
    );

    emit ItemEquipped(msg.sender, itemId, inventory.length - 1);
  }

  /**
   * @dev Unequip an item
   * @param slotIndex Inventory slot index
   */
  function unequipItem(uint256 slotIndex) external {
    require(slotIndex < playerInventory[msg.sender].length, "Invalid slot");
    playerInventory[msg.sender][slotIndex].isEquipped = false;
    emit ItemUnequipped(msg.sender, playerInventory[msg.sender][slotIndex].itemId);
  }

  /**
   * @dev Get player's equipped items
   * @param player Player address
   */
  function getEquippedItems(address player) external view returns (uint256[] memory) {
    InventorySlot[] memory inventory = playerInventory[player];
    uint256 count = 0;

    for (uint256 i = 0; i < inventory.length; i++) {
      if (inventory[i].isEquipped) count++;
    }

    uint256[] memory equipped = new uint256[](count);
    uint256 idx = 0;

    for (uint256 i = 0; i < inventory.length; i++) {
      if (inventory[i].isEquipped) {
        equipped[idx++] = inventory[i].itemId;
      }
    }

    return equipped;
  }

  /**
   * @dev Get player inventory size
   * @param player Player address
   */
  function getInventorySize(address player) external view returns (uint256) {
    return playerInventory[player].length;
  }

  /**
   * @dev Disable recipe
   * @param recipeId Recipe ID to disable
   */
  function disableRecipe(uint256 recipeId) external onlyRole(GAME_MASTER_ROLE) {
    require(recipeId < recipeCountTotal, "Invalid recipe");
    recipes[recipeId].active = false;
  }

  /**
   * @dev Get recipe details
   * @param recipeId Recipe ID
   */
  function getRecipe(uint256 recipeId)
    external
    view
    returns (CraftingRecipe memory)
  {
    require(recipeId < recipeCountTotal, "Invalid recipe");
    return recipes[recipeId];
  }

  // Override required functions
  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC1155Upgradeable, AccessControlUpgradeable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyOwner
  {}
}