const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NeemOSStakingModule", (m) => {
  // Use CapitalV2 as both token and reward token
  const neemToken = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"; // CapitalV2 address
  const rewardToken = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"; // CapitalV2 address

  // Deploy NeemOSStaking
  const staking = m.contract("NeemOSStaking", [neemToken, rewardToken]);

  return { staking };
});
