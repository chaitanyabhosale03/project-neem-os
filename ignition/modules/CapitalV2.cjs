const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NeemOSCapitalV2Module", (m) => {
  const assetName = m.getParameter("assetName", "Premium Real Estate Fund");
  const assetCategory = m.getParameter("assetCategory", "Real Estate");
  
  // For local testing, use zero addresses (allowed now with updated constructor)
  // In production, replace with actual Chainlink oracle and USDC addresses
  const chainlinkPriceFeed = m.getParameter(
    "priceFeed",
    "0x0000000000000000000000000000000000000000" // Zero for testing
  );
  
  const stablecoin = m.getParameter(
    "stablecoin",
    "0x0000000000000000000000000000000000000000" // Zero for testing
  );

  // Deploy NeemOSCapitalV2
  const capitalV2 = m.contract("NeemOSCapitalV2", [
    assetName,
    assetCategory,
    chainlinkPriceFeed,
    stablecoin
  ]);

  return { capitalV2 };
});
