const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("AuthorityRegistryModule", (m) => {
  const authorityRegistry = m.contract("AuthorityRegistry");

  return { authorityRegistry };
});