import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NeemOSCapitalModule", (m) => {
  // Tokenizing the Dubai Skyline Residency with 1,000,000 initial shares
  const capital = m.contract("NeemOSCapital", ["Dubai Residency Shares", "DRS"]);
  return { capital };
});