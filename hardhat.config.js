import "@nomicfoundation/hardhat-toolbox";

export default {
  solidity: {
    version: "0.8.24",
    settings: {
      evmVersion: "cancun" // <-- This unlocks the mcopy instruction
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    }
  }
};