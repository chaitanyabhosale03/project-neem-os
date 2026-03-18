# NEEM-OS Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Node.js 18+ installed
- npm or yarn package manager
- A terminal/command line

### Step 1: Install Dependencies
```bash
npm install
```

### Step 2: Configuration
```bash
cp .env.example .env
# Edit .env file with your settings if needed
# For local development, the defaults should work fine
```

### Step 3: Start Local Blockchain
```bash
npm run hardhat:node
```

**Output:**
```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545

Accounts:
========
(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
(1) 0x70997970C51812e339D9B73b90422E1e9c027e8a (10000 ETH)
...and 18 more accounts
```

### Step 4: Deploy Contracts (New Terminal)
```bash
# Compile first
npm run hardhat:compile

# Deploy V2 contracts (recommended)
npm run deploy:v2
```

### Step 5: Verify Deployment
```bash
npx hardhat ignition verify localhost
```

---

## 🎮 Using the Contracts

### Via Hardhat Console
```bash
npm run hardhat:console
```

### Interact with NeemOSNexusV2 (Gaming)
```javascript
// Get contract instance
const nexusV2 = await ethers.getContractAt(
  "NeemOSNexusV2",
  "0x..." // Use deployed address from ignition output
);

// Add a crafting recipe
await nexusV2.addRecipe(
  [1, 2],     // Input items: 1 and 2
  [2, 1],     // Amounts: 2 of item 1, 1 of item 2
  3,          // Output item: 3
  1,          // Output amount: 1
  3600        // Crafting time: 1 hour
);

// Mint items
await nexusV2.mintGameItem(deployer.address, 1, 100);

// Craft
await nexusV2.craft(0);

// Check balance
const balance = await nexusV2.balanceOf(deployer.address, 3);
console.log("Crafted items:", balance.toString());
```

### Interact with NeemOSCapitalV2 (RWA Finance)
```javascript
const capitalV2 = await ethers.getContractAt(
  "NeemOSCapitalV2",
  "0x..." // Deployed address
);

// Invest ETH
await capitalV2.invest({ value: ethers.parseEther("1.0") });

// Stake shares
const balance = await capitalV2.balanceOf(deployer.address);
await capitalV2.approve(capitalV2.address, balance);
await capitalV2.stake(balance);

// Check pending rewards
const rewards = await capitalV2.getPendingReward(deployer.address);
console.log("Pending rewards:", ethers.formatEther(rewards));
```

### Interact with NeemOSVerifyV2 (Identity)
```javascript
const verifyV2 = await ethers.getContractAt(
  "NeemOSVerifyV2",
  "0x..." // Deployed address
);

// Issue a credential
const tx = await verifyV2.issueCredential(
  recipient.address,
  0,                  // KYC type
  "KYC Verification",
  "NEEM Auth",
  "ipfs://kyc-metadata",
  0                   // No expiration
);

const receipt = await tx.wait();
console.log("Credential issued:", tx.hash);

// Check if credential is valid
const isValid = await verifyV2.isCredentialValid(0);
console.log("Credential valid:", isValid);
```

### Interact with NeemOSStaking
```javascript
const staking = await ethers.getContractAt(
  "NeemOSStaking",
  "0x..." // Deployed address
);

// Approve NEEM tokens
const neemToken = await ethers.getContractAt("IERC20", "0x...");
await neemToken.approve(staking.address, ethers.parseEther("1000"));

// Stake in Bronze tier
const lockEndTime = await staking.stake(ethers.parseEther("100"), 0);

// Check pending rewards
const pending = await staking.getPendingReward(deployer.address);
console.log("Pending rewards:", ethers.formatEther(pending));

// Claim rewards
await staking.claimRewards();
```

---

## 📊 Key Contract Addresses

After deployment, you'll see addresses like:

```
NeemOSNexusV2: 0x...
NeemOSCapitalV2: 0x...
NeemOSVerifyV2: 0x...
NeemOSStaking: 0x...
```

Save these for later use!

---

## 🧪 Running Tests

```bash
npm run test
```

Expected output:
```
✓ should craft items correctly
✓ should issue credentials correctly
✓ should stake and earn rewards
✓ should calculate APY correctly
```

---

## 📚 Full Documentation

For detailed information about:
- Contract architecture
- Advanced features
- Deployment to testnets
- Integration guide

See [UPGRADE_GUIDE_V2.md](./UPGRADE_GUIDE_V2.md)

---

## 🐛 Troubleshooting

### Node Server Won't Start
```bash
# Kill existing processes
taskkill /F /IM node.exe

# Clear cache and restart
npm run clean
npm run hardhat:node --reset
```

### Compilation Errors
```bash
# Full clean build
npm run hardhat:compile --reset
```

### Out of Gas
The default gas limit is 5,000,000. Adjust in `hardhat.config.cjs`:
```javascript
networks: {
  localhost: {
    gasPrice: 875000000,
    initialBaseFeePerGas: 0
  }
}
```

---

## 🎯 Next Steps

1. ✅ Deploy contracts (see above)
2. 🎮 Try the gaming contract - create items and craft
3. 💰 Invest in the capital contract - earn dividends
4. 🔐 Issue credentials - verify identities
5. 🏦 Stake tokens - earn APY rewards
6. 🚀 Build your frontend - use [wagmi](https://wagmi.sh) + [viem](https://viem.sh)

---

## 📞 Support

- **Docs**: See UPGRADE_GUIDE_V2.md
- **Issues**: Create a GitHub issue
- **Discord**: Join our community

---

**Happy Building! 🚀**
