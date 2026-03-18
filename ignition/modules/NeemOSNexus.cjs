import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NeemOSNexusModule", (m) => {
  const nexus = m.contract("NeemOSNexus");
  return { nexus };
});