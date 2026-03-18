const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NeemOSVerifyV2Module", (m) => {
  // Deploy NeemOSVerifyV2
  const verifyV2 = m.contract("NeemOSVerifyV2");

  return { verifyV2 };
});
