# 🚀 NEEM-OS V2 Quick Verification Steps

## 📍 TL;DR - The Quick Path (10 minutes)

Follow these 5 steps to verify everything works:

### **STEP 1: Install & Verify (1 min)**
```powershell
cd "C:\Users\chait\Desktop\Project NEEM-OS\neem-os"
npm install
npm list hardhat
```
✅ Should show: `hardhat@2.28.6`

---

### **STEP 2: Compile (1 min)**
```powershell
npm run hardhat:compile
```
✅ Should show: `Compilation successful`

---

### **STEP 3: Start Node - TERMINAL 1 (Keep it running)**
```powershell
npm run hardhat:node
```
✅ Should show accounts with 10000 ETH each

---

### **STEP 4: Deploy Contracts - TERMINAL 2 (New)**
```powershell
cd "C:\Users\chait\Desktop\Project NEEM-OS\neem-os"
npm run deploy:v2
```
✅ Should show 4 contract addresses:
```
NeemOSNexusV2: 0x...
NeemOSCapitalV2: 0x...
NeemOSVerifyV2: 0x...
NeemOSStaking: 0x...
```

💾 **SAVE THESE ADDRESSES!**

---

### **STEP 5: Test Contracts - TERMINAL 3 (New)**
```powershell
cd "C:\Users\chait\Desktop\Project NEEM-OS\neem-os"
npm run hardhat:console
```

Then paste this code:
```javascript
const [signer] = await ethers.getSigners();
const nexus = await ethers.getContractAt("NeemOSNexusV2", "0x...PASTE_YOUR_ADDRESS");
const capital = await ethers.getContractAt("NeemOSCapitalV2", "0x...PASTE_YOUR_ADDRESS");
const verify = await ethers.getContractAt("NeemOSVerifyV2", "0x...PASTE_YOUR_ADDRESS");
const staking = await ethers.getContractAt("NeemOSStaking", "0x...PASTE_YOUR_ADDRESS");

console.log("✅ Gaming Contract Connected:", nexus.address);
console.log("✅ Finance Contract Connected:", capital.address);
console.log("✅ Identity Contract Connected:", verify.address);
console.log("✅ Staking Contract Connected:", staking.address);
```

✅ Should show all 4 addresses

---

## 🎮 Quick Contract Tests

### Test 1: Gaming (Crafting)
```javascript
// Mint items
await nexus.mintGameItem(signer.address, 1, 100);
await nexus.mintGameItem(signer.address, 2, 50);

// Create recipe: 2 item1 + 1 item2 → 1 item3
await nexus.addRecipe([1, 2], [2, 1], 3, 1, 0);

// Craft
await nexus.craft(0);

// Verify
const result = await nexus.balanceOf(signer.address, 3);
console.log("✅ Crafted", result.toString(), "items");
```

---

### Test 2: Finance (Investment)
```javascript
// Invest 1 ETH
await capital.invest({ value: ethers.parseEther("1.0") });

// Check shares
const shares = await capital.balanceOf(signer.address);
console.log("✅ Received", ethers.formatEther(shares), "NCAP shares");

// Check price
const price = await capital.getLatestPrice();
console.log("✅ ETH Price:", price.toString());
```

---

### Test 3: Identity (Credentials)
```javascript
// Issue credential
await verify.issueCredential(
  signer.address, 0, "KYC Pass", "NEEM", "ipfs://data", 0
);

// Check credential
const cred = await verify.getCredential(0);
console.log("✅ Credential issued:", cred.credentialName);
console.log("✅ Status:", cred.status === 0 ? "ACTIVE" : "OTHER");
```

---

### Test 4: Staking (Tiers)
```javascript
// Get tiers
const tiers = await staking.getTiers();
console.log("✅ Available", tiers.length, "staking tiers");

tiers.forEach((tier, i) => {
  console.log(`  Tier ${i}: ${tier.apyPercentage/100}% APY`);
});
```

---

## 📊 Visual Progress

```
┌─────────────────────────────────────┐
│  STEP 1: Install Dependencies       │  ⏱️  1 min
└─────────────────────────────────────┘
              ⬇️  (npm install)
┌─────────────────────────────────────┐
│  STEP 2: Compile Contracts          │  ⏱️  1 min
└─────────────────────────────────────┘
              ⬇️  (npm run hardhat:compile)
┌─────────────────────────────────────┐
│  STEP 3: Start Blockchain Node      │  ⏱️  Terminal 1
│  (Keep Running)                     │     (npm run hardhat:node)
└─────────────────────────────────────┘
              ⬇️  (New Terminal)
┌─────────────────────────────────────┐
│  STEP 4: Deploy All Contracts       │  ⏱️  2 min
│  (Terminal 2)                       │     (npm run deploy:v2)
└─────────────────────────────────────┘
              ⬇️  (New Terminal)
┌─────────────────────────────────────┐
│  STEP 5: Test Contracts             │  ⏱️  Terminal 3
│  (Hardhat Console)                  │     (npm run hardhat:console)
└─────────────────────────────────────┘
              ⬇️  (Run test code)
┌─────────────────────────────────────┐
│  ✅ ALL WORKING!                    │
└─────────────────────────────────────┘
```

---

## 🎯 What Each Contract Does

| Contract | Function | Test It | Expect |
|----------|----------|---------|--------|
| **NexusV2** | Create & craft game items | `nexus.craft(0)` | Item count increases |
| **CapitalV2** | Invest & earn yield | `capital.invest({value: ...})` | NCAP shares received |
| **VerifyV2** | Issue credentials | `verify.issueCredential(...)` | Credential ID = 0 |
| **Staking** | Lock tokens for APY | `staking.getTiers()` | 4 tiers shown |

---

## ⚠️ Common Mistakes

❌ **Mistake 1**: Only opening 1 terminal
- ✅ **Fix**: Open 3 terminals (Node, Deploy, Console)

❌ **Mistake 2**: Closing node terminal
- ✅ **Fix**: Keep Terminal 1 running the whole time

❌ **Mistake 3**: Using wrong contract address
- ✅ **Fix**: Copy address from deploy output (Step 4)

❌ **Mistake 4**: Not installing dependencies first
- ✅ **Fix**: Always run `npm install` first

---

## 🔄 If Something Breaks

**Quick Reset:**
```powershell
# Terminal 1: Stop node (Ctrl+C)

# Terminal 2: Clean and reinstall
npm run clean
npm install

# Terminal 1: Start fresh
npm run hardhat:node

# Terminal 2: Redeploy
npm run deploy:v2

# Terminal 3: Test again
npm run hardhat:console
```

---

## 📈 Success Metrics

You'll know it's working when:

```
✅ npm install completes without errors
✅ npm run hardhat:compile shows "Compilation successful"
✅ npm run hardhat:node shows 20 accounts with 10000 ETH each
✅ npm run deploy:v2 shows 4 contract addresses
✅ Hardhat console connects without errors
✅ Test code runs and shows contract addresses
✅ Crafting creates new items
✅ Investment receives shares
✅ Credentials can be issued
✅ Staking tiers are visible
```

---

## 📞 Need Help?

1. **For detailed steps**: Read `VERIFICATION_GUIDE.md`
2. **For advanced features**: Read `UPGRADE_GUIDE_V2.md`
3. **For quick setup**: Read `QUICKSTART.md`
4. **For changes**: Read `CHANGES.md`

---

## 🎉 Ready to Start?

```powershell
# Follow these 5 steps in order:

# 1. Install
npm install

# 2. Compile
npm run hardhat:compile

# 3. Terminal 1
npm run hardhat:node

# 4. Terminal 2
npm run deploy:v2

# 5. Terminal 3
npm run hardhat:console
```

**Total Time**: ~10 minutes ⏱️

Have fun building! 🚀
