import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NeemOSVerifyModule", (m) => {
  const verify = m.contract("NeemOSVerify");
  return { verify };
});