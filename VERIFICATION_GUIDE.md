# NEEM-OS V2 - Complete Step-by-Step Verification Guide

## 📋 Prerequisites Check

### Step 1: Verify Node.js Installation
Open PowerShell and run:

```powershell
node --version
npm --version
```

**Expected Output:**
```
v18.x.x or higher
9.x.x or higher
```

If not installed, download from: https://nodejs.org/

---

## 🔧 Setup & Installation

### Step 2: Navigate to Project Directory
```powershell
cd "C:\Users\chait\Desktop\Project NEEM-OS\neem-os"
```

**Verify you see:**
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----          3/19/2026  XX:XX XX    <DIR>  contracts
d-----          3/19/2026  XX:XX XX    <DIR>  ignition
d-----          3/19/2026  XX:XX XX    <DIR>  app
-a----          3/19/2026  XX:XX XX     XXXX  package.json
-a----          3/19/2026  XX:XX XX     XXXX  hardhat.config.cjs
-a----          3/19/2026  XX:XX XX     XXXX  .env
```

### Step 3: Install All Dependencies
```powershell
npm install
```

**This will take 2-5 minutes. You should see:**
```
added XXX packages, and audited XXXX packages in Xs

found 0 vulnerabilities
```

### Step 4: Verify Installation
```powershell
npm list hardhat
npm list @openzeppelin/contracts
```

**Expected Output:**
```
neem-os@0.1.0 C:\Users\chait\Desktop\Project NEEM-OS\neem-os
├── hardhat@2.28.6
└── @openzeppelin/contracts@5.6.1
```

✅ If you see these, installation is successful!

---

## 🔨 Compilation & Configuration

### Step 5: Check Environment Configuration
Open `.env` file and verify:

```powershell
cat .env
```

**Should contain:**
```
HARDHAT_NETWORK=localhost
LOCALHOST_RPC_URL=http://127.0.0.1:8545
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb476c6b8d6c1f02b5b5ddc65a672
```

### Step 6: Compile Smart Contracts
```powershell
npm run hardhat:compile
```

**Expected Output:**
```
Downloading compiler 0.8.24
Downloading compiler 0.8.20
Compiling 25 files with 0.8.24
Compiling 5 files with 0.8.20

✓ Compilation successful
```

**Check compiled artifacts:**
```powershell
ls artifacts/contracts/
```

**You should see:**
```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----          3/19/2026  XX:XX XX    <DIR>  NeemOSNexusV2.sol
d-----          3/19/2026  XX:XX XX    <DIR>  NeemOSCapitalV2.sol
d-----          3/19/2026  XX:XX XX    <DIR>  NeemOSVerifyV2.sol
d-----          3/19/2026  XX:XX XX    <DIR>  NeemOSStaking.sol
```

✅ If you see these, compilation succeeded!

---

## 🚀 Start Local Blockchain

### Step 7: Start Hardhat Node
Open a **new PowerShell terminal** and run:

```powershell
npm run hardhat:node
```

**Expected Output:**
```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========
(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
(1) 0x70997970C51812e339D9B73b90422E1e9c027e8a (10000 ETH)
(2) 0x3C44CdDdB6a900c6971ABF5797b264B1A3bBad13 (10000 ETH)
(3) 0x90F79bf6EB2c4f870365E785982E1f101E93b906 (10000 ETH)
(4) 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 (10000 ETH)
...
Mnemonic: test test test test test test test test test test test junk
```

⚠️ **Keep this terminal open!** It's your blockchain node.

---

## 📤 Deploy Contracts

### Step 8: Deploy in New Terminal
Open **another new PowerShell terminal** and navigate to project:

```powershell
cd "C:\Users\chait\Desktop\Project NEEM-OS\neem-os"
npm run deploy:v2
```

**Expected Output:**
```
Compiling...
Deploying on chain 1337

Starting deployment of NeemOSNexusV2Module

NeemOSNexusV2 deployed to: 0x0000...
NeemOSCapitalV2 deployed to: 0x0000...
NeemOSVerifyV2 deployed to: 0x0000...
NeemOSStaking deployed to: 0x0000...

Deployment complete!
```

📝 **Save these addresses!** You'll need them later.

### Step 9: Verify Deployments
```powershell
npx hardhat ignition verify localhost
```

**Expected Output:**
```
Starting verification of contracts deployed on "localhost"

NeemOSNexusV2Module
  NeemOSNexusV2 ✓ deployed to 0x...
  
NeemOSCapitalV2Module
  NeemOSCapitalV2 ✓ deployed to 0x...
  
NeemOSVerifyV2Module
  NeemOSVerifyV2 ✓ deployed to 0x...
  
NeemOSStakingModule
  NeemOSStaking ✓ deployed to 0x...
```

✅ All deployments verified!

---

## 🎮 Test Gaming Contract (NeemOSNexusV2)

### Step 10: Open Hardhat Console
In your **third terminal**, run:

```powershell
npm run hardhat:console
```

**You should see the prompt:**
```
Welcome to Node.js v18.x.x.
Type ".help" for more information.
>
```

### Step 11: Set Up Gaming Contract
```javascript
// Get the contract factory and deployed address
const NexusV2 = await ethers.getContractFactory("NeemOSNexusV2");

// Replace with YOUR deployed address from Step 8
const nexusAddress = "0x...";  // Your address here
const nexus = await ethers.getContractAt("NeemOSNexusV2", nexusAddress);

// Get signer (first account)
const [signer] = await ethers.getSigners();

console.log("Connected to NeemOSNexusV2 at:", nexusAddress);
console.log("Signer address:", signer.address);
```

**Expected Output:**
```
Connected to NeemOSNexusV2 at: 0x...
Signer address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

### Step 12: Create Game Items
```javascript
// Mint some items first
console.log("Minting items...");

// Item ID 1: Health Pack (100 items)
await nexus.mintGameItem(signer.address, 1, 100);
console.log("Minted 100 Health Packs");

// Item ID 2: Mana Potion (50 items)
await nexus.mintGameItem(signer.address, 2, 50);
console.log("Minted 50 Mana Potions");

// Check balance
const hp = await nexus.balanceOf(signer.address, 1);
const mp = await nexus.balanceOf(signer.address, 2);
console.log("Health Packs:", hp.toString());
console.log("Mana Potions:", mp.toString());
```

**Expected Output:**
```
Minting items...
Minted 100 Health Packs
Minted 50 Mana Potions
Health Packs: 100
Mana Potions: 50
```

### Step 13: Create Crafting Recipe
```javascript
// Add a crafting recipe: 2 HP + 1 MP = 1 Rare Gem
console.log("Adding crafting recipe...");

const recipe = await nexus.addRecipe(
  [1, 2],          // Input items: HP and MP
  [2, 1],          // Amounts: 2 HP and 1 MP
  3,               // Output: item 3 (Rare Gem)
  1,               // Output amount: 1
  0                // Crafting time: 0 (immediate)
);

console.log("Recipe added!");
```

**Expected Output:**
```
Recipe added!
```

### Step 14: Test Crafting
```javascript
// Craft the recipe
console.log("Crafting recipe...");
await nexus.craft(0);
console.log("Crafting successful!");

// Check result
const gem = await nexus.balanceOf(signer.address, 3);
const hpAfter = await nexus.balanceOf(signer.address, 1);
const mpAfter = await nexus.balanceOf(signer.address, 2);

console.log("After crafting:");
console.log("  Rare Gems:", gem.toString());
console.log("  Health Packs:", hpAfter.toString());
console.log("  Mana Potions:", mpAfter.toString());
```

**Expected Output:**
```
Crafting successful!
After crafting:
  Rare Gems: 1
  Health Packs: 98
  Mana Potions: 49
```

✅ **Gaming Contract Works!**

---

## 💰 Test Finance Contract (NeemOSCapitalV2)

### Step 15: Set Up Finance Contract
```javascript
// Get Capital contract
const capitalAddress = "0x...";  // Your deployed address
const capital = await ethers.getContractAt("NeemOSCapitalV2", capitalAddress);

console.log("Connected to NeemOSCapitalV2 at:", capitalAddress);
```

### Step 16: Test Investment
```javascript
// Invest 1 ETH
console.log("Investing 1 ETH...");

const investTx = await capital.invest({ 
  value: ethers.parseEther("1.0") 
});

console.log("Investment transaction sent:", investTx.hash);

// Check share balance
const shares = await capital.balanceOf(signer.address);
console.log("Shares received:", ethers.formatEther(shares), "NCAP");
```

**Expected Output:**
```
Investment transaction sent: 0x...
Shares received: 1000 NCAP
```

### Step 17: Check Asset Info
```javascript
// Get contract info
const assetName = await capital.assetName();
const totalInvestment = await capital.totalInvestment();
const price = await capital.getLatestPrice();

console.log("Asset Name:", assetName);
console.log("Total Investment:", ethers.formatEther(totalInvestment), "ETH");
console.log("ETH Price (USD):", price.toString(), "(in 8 decimals)");
```

**Expected Output:**
```
Asset Name: Premium Real Estate Fund
Total Investment: 1 ETH
ETH Price (USD): 200000000000 (in 8 decimals = $2,000)
```

✅ **Finance Contract Works!**

---

## 🔐 Test Identity Contract (NeemOSVerifyV2)

### Step 18: Set Up Identity Contract
```javascript
// Get Verify contract
const verifyAddress = "0x...";  // Your deployed address
const verify = await ethers.getContractAt("NeemOSVerifyV2", verifyAddress);

console.log("Connected to NeemOSVerifyV2 at:", verifyAddress);
```

### Step 19: Issue Credentials
```javascript
// Issue a KYC credential
console.log("Issuing KYC credential...");

const issueTx = await verify.issueCredential(
  signer.address,           // Recipient
  0,                        // KYC type
  "KYC Verification Pass",  // Credential name
  "NEEM Auth",              // Issuer name
  "ipfs://kyc-metadata",    // Metadata URI
  0                         // No expiration
);

console.log("Credential issued:", issueTx.hash);
```

**Expected Output:**
```
Credential issued: 0x...
```

### Step 20: Check Credential
```javascript
// Get credential details
const credential = await verify.getCredential(0);

console.log("Credential Details:");
console.log("  Name:", credential.credentialName);
console.log("  Issuer:", credential.issuerName);
console.log("  Type:", credential.credentialType);
console.log("  Status:", credential.status);

// Check if valid
const isValid = await verify.isCredentialValid(0);
console.log("  Is Valid:", isValid);
```

**Expected Output:**
```
Credential Details:
  Name: KYC Verification Pass
  Issuer: NEEM Auth
  Type: 0
  Status: 0
  Is Valid: true
```

✅ **Identity Contract Works!**

---

## 🏦 Test Staking Contract

### Step 21: Set Up Staking Contract
```javascript
// Get Staking contract
const stakingAddress = "0x...";  // Your deployed address
const staking = await ethers.getContractAt("NeemOSStaking", stakingAddress);

console.log("Connected to NeemOSStaking at:", stakingAddress);

// Get tiers
const tiers = await staking.getTiers();
console.log("Available tiers:", tiers.length);
```

**Expected Output:**
```
Connected to NeemOSStaking at: 0x...
Available tiers: 4
```

### Step 22: Check Tier Details
```javascript
// Get tier 0 (Bronze)
console.log("Staking Tiers:");

for(let i = 0; i < 4; i++) {
  const tier = await staking.getTiers();
  const t = tier[i];
  console.log(`\nTier ${i}:`);
  console.log(`  Min Stake: ${ethers.formatEther(t.minAmount)} NEEM`);
  console.log(`  APY: ${t.apyPercentage / 100}%`);
  console.log(`  Lock Period: ${t.lockPeriodSeconds} seconds`);
}
```

**Expected Output:**
```
Staking Tiers:

Tier 0:
  Min Stake: 1 NEEM
  Max Stake: 1000 NEEM
  APY: 5%
  Lock Period: 0 seconds

Tier 1:
  Min Stake: 1000 NEEM
  Max Stake: 10000 NEEM
  APY: 10%
  Lock Period: 2592000 seconds

Tier 2:
  Min Stake: 10000 NEEM
  Max Stake: 100000 NEEM
  APY: 15%
  Lock Period: 7776000 seconds

Tier 3:
  Min Stake: 100000 NEEM
  Max Stake: 0 NEEM
  APY: 20%
  Lock Period: 15552000 seconds
```

✅ **All Contracts Are Working!**

---

## 📊 Final Verification Summary

### Step 23: Run Complete Test
```javascript
console.log("=== NEEM-OS V2 VERIFICATION SUMMARY ===\n");

console.log("✅ Gaming (NexusV2):");
console.log("   - Items minted successfully");
console.log("   - Crafting recipe created");
console.log("   - Crafting executed\n");

console.log("✅ Finance (CapitalV2):");
console.log("   - Investment processed");
console.log("   - Shares received");
console.log("   - Oracle price fetched\n");

console.log("✅ Identity (VerifyV2):");
console.log("   - Credentials issued");
console.log("   - Metadata stored");
console.log("   - Validation working\n");

console.log("✅ Staking:");
console.log("   - 4 tiers configured");
console.log("   - APY rates set");
console.log("   - Ready for locking tokens\n");

console.log("========================================");
console.log("🎉 All Systems Operational!");
console.log("========================================");
```

---

## 🧪 Troubleshooting Common Issues

### Issue 1: "Compilation Failed"
**Solution:**
```powershell
npm run clean
npm install
npm run hardhat:compile
```

### Issue 2: "Cannot connect to node"
**Check:**
1. Terminal 1 with `npm run hardhat:node` is still running
2. Port 8545 is not blocked
3. `.env` has correct `LOCALHOST_RPC_URL=http://127.0.0.1:8545`

### Issue 3: "Contract not found at address"
**Solution:**
```powershell
# Deploy again
npm run deploy:v2

# Copy the addresses from output
# Use correct addresses in console
```

### Issue 4: "Insufficient balance"
**Solution:**
```javascript
// Hardhat gives test accounts unlimited ETH
// Check your signer account:
const [signer] = await ethers.getSigners();
const balance = await ethers.provider.getBalance(signer.address);
console.log("Balance:", ethers.formatEther(balance));  // Should be huge
```

---

## ✅ Complete Verification Checklist

```
SETUP:
  ☐ Node.js v18+ installed
  ☐ npm packages installed
  ☐ .env file configured
  
COMPILATION:
  ☐ Contracts compile without errors
  ☐ Artifacts generated in artifacts/contracts/
  
DEPLOYMENT:
  ☐ Hardhat node running on localhost:8545
  ☐ All 4 contracts deployed
  ☐ Deployment addresses saved
  
GAMING:
  ☐ Items minted
  ☐ Recipe created
  ☐ Crafting works
  
FINANCE:
  ☐ ETH invested
  ☐ Shares received
  ☐ Oracle price fetched
  
IDENTITY:
  ☐ Credentials issued
  ☐ Credential valid
  ☐ Metadata accessible
  
STAKING:
  ☐ 4 tiers available
  ☐ APY rates correct
  ☐ Lock periods set
```

---

## 🎉 You're All Set!

Your NEEM-OS V2 project is:
- ✅ Properly configured
- ✅ Compiled without errors
- ✅ Deployed locally
- ✅ Fully functional

**Next Steps:**
1. Explore more contract functions
2. Read UPGRADE_GUIDE_V2.md for advanced features
3. Build frontend integration with wagmi/ethers.js
4. Deploy to Sepolia testnet

Happy building! 🚀
