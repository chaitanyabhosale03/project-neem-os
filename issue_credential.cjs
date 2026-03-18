import hre from "hardhat";

async function main() {
  const contractAddress = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853";
  const myWalletAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

  // Use the modern ethers access via hre
  const verify = await hre.ethers.getContractAt("NeemOSVerify", contractAddress);

  console.log("--------------------------------------------------");
  console.log("ISSUE STATUS: Initiating Credential Mint...");
  
  const tx = await verify.issueCredential(myWalletAddress);
  await tx.wait();

  console.log("SUCCESS: Web3 Architect Credential bound to:", myWalletAddress);
  console.log("--------------------------------------------------");
}

main().catch((error) => {
  console.error("MINTING FAILED:", error);
  process.exit(1);
});