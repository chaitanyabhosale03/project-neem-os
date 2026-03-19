const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NeemOSNexusV2Module", (m) => {
  // Deploy NeemOSNexusV2 contract directly (non-upgradeable deployment for localhost)
  const nexusV2 = m.contract("NeemOSNexusV2");

  return { nexusV2 };
});