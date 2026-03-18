const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NeemOSStakingModule", (m) => {
  // NEEM token address (deploy your own ERC20 or use existing)
  const neemToken = m.getParameter(
    "neemToken",
    "0x0000000000000000000000000000000000000000" // Replace with actual NEEM token
  );
  
  // Reward token (can be same as NEEM or different)
  const rewardToken = m.getParameter("rewardToken", neemToken);

  // Deploy NeemOSStaking
  const staking = m.contract("NeemOSStaking", [neemToken, rewardToken]);

  return { staking };
});
