const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("SignatureModule", (m) => {
  const signature = m.contract("Signature");

  return { signature };
});