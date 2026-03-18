const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NeemOSNexusV2Module", (m) => {
  const uri = m.getParameter("uri", "ipfs://QmYourNexusMetadataCID/{id}.json");

  // Deploy NeemOSNexusV2 with UUPS proxy pattern
  const nexusV2 = m.contract("NeemOSNexusV2");

  // Initialize the proxy with URI
  m.call(nexusV2, "initialize", [uri]);

  return { nexusV2 };
});