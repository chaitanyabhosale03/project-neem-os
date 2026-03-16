import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NeemOSModule", (m) => {
  const neemOS = m.contract("NeemOS");
  return { neemOS };
});