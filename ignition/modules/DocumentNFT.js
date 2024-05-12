const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DocumentNFTModule", (m) => {
  const authorityRegistryAddress = m.getParameter("authorityRegistryAddress");
  const signatureAddress = m.getParameter("signatureAddress");
  const baseURI = m.getParameter("baseURI");

  const documentNFT = m.contract("DocumentNFT", [authorityRegistryAddress, signatureAddress, baseURI]);

  return { documentNFT };
});