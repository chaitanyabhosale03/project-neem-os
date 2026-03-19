# NEEM-OS V2 Deployment Addresses

**Network:** Localhost (Chain ID: 1337)  
**RPC URL:** http://127.0.0.1:8545  
**Deployed At:** 2024 (Fresh Deployment)

## Contract Addresses

### NeemOSNexusV2 (Gaming & Crafting)
- **Address:** `0x5FC8d32690cc91D4c39d9d3abcBD16989F875707`
- **Features:** ERC1155 crafting, rarity system, inventory management
- **Status:** ✅ Live

### NeemOSCapitalV2 (RWA Finance)
- **Address:** `0x0165878A594ca255338adfa4d48449f69242Eb8F`
- **Features:** ERC20 tokenization, Chainlink price feeds, staking, vesting
- **Status:** ✅ Live

### NeemOSVerifyV2 (Identity & Credentials)
- **Address:** `0xa513E6E4b8f2a923D98304ec87F64353C4D5C853`
- **Features:** Soulbound tokens, zero-knowledge proof ready, credential management
- **Status:** ✅ Live

### NeemOSStaking (Multi-Tier Staking)
- **Address:** `0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6`
- **Staking Token:** NeemOSCapitalV2 (0x0165878A594ca255338adfa4d48449f69242Eb8F)
- **Reward Token:** NeemOSCapitalV2 (0x0165878A594ca255338adfa4d48449f69242Eb8F)
- **Features:** Bronze (5%), Silver (10%), Gold (15%), Platinum (20%) APY tiers
- **Status:** ✅ Live

## Testing Commands

```bash
# Start Hardhat console
npm run hardhat:console

# Compile contracts
npm run hardhat:compile

# Deploy again (all contracts)
npm run deploy:v2
```

## Quick Test Examples

### Nexus - Add Crafting Recipe
```javascript
const nexus = await ethers.getContractAt("NeemOSNexusV2", "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707");
await nexus.addRecipe(1, [100, 200], 3600, 1);
```

### Capital - Invest ETH
```javascript
const capital = await ethers.getContractAt("NeemOSCapitalV2", "0x0165878A594ca255338adfa4d48449f69242Eb8F");
await capital.invest({ value: ethers.parseEther("1") });
```

### Verify - Issue Credential
```javascript
const verify = await ethers.getContractAt("NeemOSVerifyV2", "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853");
await verify.issueCredential("0xaddress", 2, "KYC verification", 1893456000);
```

### Staking - Stake Tokens
```javascript
const staking = await ethers.getContractAt("NeemOSStaking", "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6");
await staking.stake(ethers.parseEther("100"), 2); // Stake 100 tokens in Silver tier
```

See [VERIFICATION_GUIDE.md](VERIFICATION_GUIDE.md) for comprehensive testing steps.
