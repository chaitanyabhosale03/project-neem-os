const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NeemOSCapitalV2Module", (m) => {
  const assetName = m.getParameter("assetName", "Premium Real Estate Fund");
  const assetCategory = m.getParameter("assetCategory", "Real Estate");
  
  // Sepolia testnet Chainlink ETH/USD oracle
  const chainlinkPriceFeed = m.getParameter(
    "priceFeed",
    "0x694AA1769357215DE4FAC081bf1f309aDC325306"
  );
  
  // Mock USDC for testing (deploy your own or use existing)
  const stablecoin = m.getParameter(
    "stablecoin",
    "0x0000000000000000000000000000000000000000" // Replace with actual USDC
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
