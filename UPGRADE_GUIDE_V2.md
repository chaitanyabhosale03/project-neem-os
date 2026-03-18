# NEEM-OS V2 Upgrade Guide & Deployment

## 🚀 Latest Upgrades & New Features

### **Version 2.0 Architecture**

This document outlines all the enhanced features and deployment procedures for NEEM-OS V2.

---

## 📋 V2 Contract Enhancements

### **1. NeemOSNexusV2 (Gaming - Advanced ERC-1155)**

**New Features:**
- ✅ **Crafting System**: Burn multiple items to craft higher-tier items with configurable recipes
- ✅ **Rarity System**: Items categorized by rarity (Common, Uncommon, Rare, Epic, Legendary)
- ✅ **Inventory Management**: Track and equip items with proper slot management
- ✅ **Access Control**: Role-based permissions (Game Master, Minter roles)
- ✅ **Supply Limits**: Set max supply per item
- ✅ **Soulbound Items**: Support for non-transferable game assets
- ✅ **Crafting Cooldown**: Implement crafting time requirements

**Key Functions:**
```solidity
addRecipe(inputIds, inputAmounts, outputId, outputAmount, craftingTimeSeconds)
craft(recipeId)
setItemMetadata(itemId, name, rarity, maxSupply, soulbound)
mintGameItem(to, id, amount)
equipItem(itemId)
getEquippedItems(player)
```

---

### **2. NeemOSCapitalV2 (RWA Finance - Advanced ERC-20)**

**New Features:**
- ✅ **Chainlink Price Oracle**: Real-time ETH/USD pricing for dynamic share valuation
- ✅ **Dividend History**: Track all dividend distributions
- ✅ **Staking Mechanism**: Stake shares to earn additional APY rewards
- ✅ **Vesting Schedules**: Create time-locked token releases for beneficiaries
- ✅ **Asset Valuation**: Track real-world asset value updates
- ✅ **Time-Based Rewards**: Automatic APY calculation based on staking duration
- ✅ **Role-Based Yield Management**: Separate roles for yield managers and vesting managers

**Key Features:**
- Dynamic share pricing based on asset valuation
- Automated dividend distribution
- Staking rewards: 10% default APY (configurable)
- Vesting with revocable schedules
- Price feed monitoring (1-day staleness check)

**Key Functions:**
```solidity
invest()
distributeDividends(usdcAmount)
pendingDividends(investor)
withdrawDividends()
stake(amount)
unstake(amount)
claimStakingReward()
createVestingSchedule(beneficiary, totalAmount, durationSeconds, revocable)
claimVestedTokens()
updateAssetValuation(newValuation)
getLatestPrice()
```

---

### **3. NeemOSVerifyV2 (Identity - SBT with ZKP Ready)**

**New Features:**
- ✅ **Advanced Metadata**: Rich credential information (issuer, type, expiration)
- ✅ **Credential Types**: 6 built-in types (KYC, Corporate, Educational, License, Security, Custom)
- ✅ **Revocation Management**: Revoke credentials with reasons
- ✅ **Expiration Tracking**: Auto-expire credentials after set duration
- ✅ **ZKP Integration Ready**: Commitment and proof storage structure
- ✅ **Sybil Resistance**: Check for validated credentials
- ✅ **Multiple Issuers**: Support multiple credential issuers with role control
- ✅ **Credential History**: Track all credentials per holder

**Key Features:**
- Non-transferable (Soulbound) tokens
- Comprehensive credential lifecycle: Issue → ZKP Verify → Revoke/Expire
- Multiple issuers with granular permissions
- Zero-knowledge proof ready (proof storage, commitment tracking)

**Key Functions:**
```solidity
issueCredential(to, credentialType, name, issuerName, metadataURI, expiresAt)
submitZKProof(tokenId, commitment, proof)
revokeCredential(tokenId, reason)
isCredentialValid(tokenId)
getCredential(tokenId)
passSybilCheck(user)
hasSybilCheck(user)
updateMetadata(tokenId, newMetadataURI)
getHolderCredentials(holder)
```

---

### **4. NeemOSStaking (NEW - Multi-Tier Staking Pool)**

**Complete Staking Ecosystem:**
- ✅ **Multi-Tier System**: 4 default tiers (Bronze, Silver, Gold, Platinum) with different APYs
- ✅ **Lock Periods**: Flexible to 180-day lock options
- ✅ **Dynamic APY**: Tier-based rewards (5% - 20% default)
- ✅ **Early Unstaking Penalty**: 10% default penalty for early withdrawal
- ✅ **Delegation System**: Delegate voting power while maintaining ownership
- ✅ **Reward Distribution**: Batch reward distribution by admins
- ✅ **Time-Based Accumulation**: Automatic reward calculation based on time staked
- ✅ **Voting Power**: Track voting power including delegations

**Default Tiers:**
| Tier | Min Stake | Max Stake | Lock Period | APY |
|------|-----------|-----------|-------------|-----|
| Bronze | 1 NEEM | 1,000 NEEM | Flexible | 5% |
| Silver | 1,000 NEEM | 10,000 NEEM | 30 days | 10% |
| Gold | 10,000 NEEM | 100,000 NEEM | 90 days | 15% |
| Platinum | 100,000 NEEM | Unlimited | 180 days | 20% |

**Key Functions:**
```solidity
stake(amount, tierIndex)
unstake(amount)
claimRewards()
delegatePower(delegate)
revokeDelegation()
distributeRewards(recipients, amounts)
getPendingReward(user)
addTier(minAmount, maxAmount, apyPercentage, lockPeriodSeconds)
updateTierAPY(tierIndex, newApy)
getVotingPower(user)
```

---

## 🛠️ Environment Setup

### **Step 1: Install Dependencies**

```bash
cd neem-os
npm install
npm install --save-dev dotenv
```

### **Step 2: Create .env File**

```bash
cp .env.example .env
```

**Edit .env with your values:**

```env
# Hardhat Configuration
HARDHAT_NETWORK=localhost
LOCALHOST_RPC_URL=http://127.0.0.1:8545

# Network URLs
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY

# Private Keys
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476c6b8d6c1f02b5b5ddc65a672

# APIs
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY

# Chainlink Oracle (Sepolia)
CHAINLINK_ETH_USD_SEPOLIA=0x694AA1769357215DE4FAC081bf1f309aDC325306

# Stablecoins
USDC_ADDRESS=0x0000000000000000000000000000000000000000
```

---

## 🚀 Local Development Setup

### **Step 1: Start Hardhat Node**

```bash
npx hardhat node
```

This will:
- Start a local blockchain at `http://127.0.0.1:8545`
- Create 20 test accounts with 10,000 ETH each
- Display account addresses and private keys

### **Step 2: Deploy Contracts (New Terminal)**

```bash
# Deploy V1 contracts (original)
npx hardhat ignition deploy ignition/modules/NeemOS.cjs --network localhost
npx hardhat ignition deploy ignition/modules/NeemOSCapital.cjs --network localhost
npx hardhat ignition deploy ignition/modules/NeemOSNexus.cjs --network localhost
npx hardhat ignition deploy ignition/modules/NeemOSVerify.cjs --network localhost

# Deploy V2 contracts (enhanced)
npx hardhat ignition deploy ignition/modules/NexusV2.cjs --network localhost
npx hardhat ignition deploy ignition/modules/CapitalV2.cjs --network localhost --parameters ignition/parameters.json
npx hardhat ignition deploy ignition/modules/VerifyV2.cjs --network localhost

# Deploy new staking contract
npx hardhat ignition deploy ignition/modules/NeemOSStaking.cjs --network localhost --parameters ignition/parameters.json
```

### **Step 3: Verify Deployments**

```bash
npx hardhat ignition verify localhost
```

---

## 🔍 Testing & Interaction

### **Step 1: Compile Contracts**

```bash
npx hardhat compile
```

### **Step 2: Run Hardhat Console**

```bash
npx hardhat console --network localhost
```

**Example: Interact with NeemOSNexusV2**

```javascript
const nexusV2 = await ethers.getContractAt(
  "NeemOSNexusV2",
  "0x..." // Deployed address
);

// Initialize (if not done via ignition)
await nexusV2.initialize("ipfs://QmYourURI/{id}.json");

// Add a crafting recipe
await nexusV2.addRecipe(
  [3, 4],           // Input: 2 items
  [2, 1],           // Amounts: 2 of item 3, 1 of item 4
  5,                // Output: item 5 (Dragon Armor)
  1,                // Output amount: 1
  3600              // Crafting time: 1 hour
);

// Mint items
await nexusV2.mintGameItem(ethers.provider.getSigner().address, 3, 100);
await nexusV2.mintGameItem(ethers.provider.getSigner().address, 4, 100);

// Craft the recipe
await nexusV2.craft(0);
console.log(await nexusV2.balanceOf(ethers.provider.getSigner().address, 5)); // Should show 1
```

---

## 📊 Architecture Improvements

### **Smart Contract Improvements:**

1. **Access Control**
   - Role-based permissions (ADMIN, GAME_MASTER, MINTER, ISSUER, etc.)
   - Fine-grained control over contract functions

2. **Gas Optimization**
   - Batch operations support
   - Efficient storage mappings
   - Optimized mathematical calculations

3. **Security Enhancements**
   - ReentrancyGuard for critical functions
   - Input validation on all public functions
   - Safeguards for early unstaking penalties

4. **Event Logging**
   - Comprehensive events for all major operations
   - Indexed parameters for efficient filtering
   - Audit trail for all contract interactions

5. **Upgrade Path**
   - UUPS proxy pattern for NexusV2
   - Future-proof architecture for protocol upgrades

---

## 🔧 Configuration Files

### **ignition/parameters.json** (Create this)

```json
{
  "NeemOSCapitalV2Module": {
    "assetName": "Global Real Estate Fund",
    "assetCategory": "Real Estate",
    "priceFeed": "0x694AA1769357215DE4FAC081bf1f309aDC325306",
    "stablecoin": "0x0000000000000000000000000000000000000000"
  },
  "NeemOSStakingModule": {
    "neemToken": "0x0000000000000000000000000000000000000000",
    "rewardToken": "0x0000000000000000000000000000000000000000"
  }
}
```

---

## 🧪 Testing Smart Contracts

Create `test/NeemOSV2.test.js`:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NeemOS V2 Contracts", () => {
  let nexusV2, capitalV2, verifyV2, staking;
  let owner, addr1, addr2;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy NeemOSNexusV2
    const NexusV2 = await ethers.getContractFactory("NeemOSNexusV2");
    nexusV2 = await NexusV2.deploy();
    await nexusV2.initialize("ipfs://test/{id}.json");

    // Deploy NeemOSVerifyV2
    const VerifyV2 = await ethers.getContractFactory("NeemOSVerifyV2");
    verifyV2 = await VerifyV2.deploy();
  });

  it("should craft items correctly", async () => {
    // Add recipe
    await nexusV2.addRecipe([1, 2], [2, 1], 3, 1, 0);

    // Mint inputs
    await nexusV2.mintGameItem(owner.address, 1, 5);
    await nexusV2.mintGameItem(owner.address, 2, 5);

    // Craft
    await nexusV2.craft(0);

    // Check output
    const balance = await nexusV2.balanceOf(owner.address, 3);
    expect(balance).to.equal(1);
  });

  it("should issue credentials correctly", async () => {
    const tx = await verifyV2.issueCredential(
      addr1.address,
      0, // KYC type
      "KYC Verification",
      "NEEM Auth",
      "ipfs://kyc-data",
      0  // No expiration
    );

    expect(tx).to.emit(verifyV2, "CredentialIssued");
  });
});
```

Run tests:
```bash
npx hardhat test
```

---

## 🚨 Troubleshooting

### **Issue: Hardhat node fails to start**

**Solution:**
```bash
# Kill any existing node process
taskkill /F /IM node.exe

# Start fresh
npx hardhat node --reset
```

### **Issue: Contract compilation errors**

**Solution:**
```bash
# Clean build
npx hardhat clean
npx hardhat compile

# Check for Solidity version issues
```

### **Issue: Insufficient funds for deployment**

**Solution:**
```bash
# Use hardhat's default test accounts (they have unlimited ETH)
# Edit hardhat.config.cjs to ensure accounts are configured
```

---

## 📈 Future Roadmap (V3+)

1. **Chainlink VRF Integration**
   - Random loot drops in gaming
   - Fair randomness for rewards

2. **Cross-Chain Bridges**
   - Polygon, Arbitrum, Optimism support
   - Multi-chain asset management

3. **Advanced ZKP**
   - Privacy-preserving credentials
   - Selective disclosure of KYC data

4. **DAO Governance**
   - Community voting on parameter changes
   - Decentralized protocol upgrades

5. **Mobile Integration**
   - React Native app
   - MetaMask mobile support

---

## 📞 Support & Development

- **GitHub**: [https://github.com/your-repo/neem-os](https://github.com/your-repo/neem-os)
- **Discord**: Join our developer community
- **Docs**: [https://docs.neem-os.xyz](https://docs.neem-os.xyz)

---

**Last Updated**: March 2026  
**Version**: 2.0.0
