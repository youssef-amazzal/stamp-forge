// test/TestDocumentNFT.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DocumentNFT", function () {
    before(async function () {
        this.AuthorityRegistry = await ethers.getContractFactory("AuthorityRegistry");
        this.Signature = await ethers.getContractFactory("Signature");
        this.DocumentNFT = await ethers.getContractFactory("DocumentNFT");
    });

    beforeEach(async function () {
        // Get owner and authority accounts
        [this.owner, this.authority, ...rest] = await ethers.getSigners();

        // Deploy AuthorityRegistry contract
        this.authorityRegistry = await this.AuthorityRegistry.deploy();
        await this.authorityRegistry.waitForDeployment();
        console.log("AuthorityRegistry deployed at:", await this.authorityRegistry.getAddress());

        // Deploy Signature contract
        this.signature = await this.Signature.deploy();
        await this.signature.waitForDeployment();
        console.log("Signature deployed at:", await this.signature.getAddress());

        // Deploy DocumentNFT contract
        this.documentNFT = await this.DocumentNFT.deploy(await this.authorityRegistry.getAddress(), await this.signature.getAddress(), "URI");
        await this.documentNFT.waitForDeployment();
        console.log("DocumentNFT deployed at:", await this.documentNFT.getAddress());
    });

    it("Should mint a document NFT and retrieve metadata", async function () {
        // Convert string to bytes32
        const hash = ethers.utils.formatBytes32String("hash");

        // Mint a document NFT
        await this.documentNFT.connect(this.owner).mintDocumentNFT(await this.owner.getAddress(), hash, "type", 123, 456);

        // Retrieve document metadata
        const tokenId = 1;
        const metadata = await this.documentNFT.getDocumentMetadata(tokenId);

        // Assert metadata
        expect(metadata.owner).to.equal(this.owner.getAddress());
        expect(metadata.documentType).to.equal("type");
        // Add more assertions for other metadata fields
    });

    it("Should sign a document and verify the signature", async function () {
        // Convert string to bytes32
        const hash = ethers.utils.formatBytes32String("hash");

        // Mint a document NFT
        await this.documentNFT.connect(this.owner).mintDocumentNFT(await this.owner.getAddress(), hash, "type", 123, 456);

        // Sign the document
        await this.documentNFT.connect(this.authority).signDocument(1);

        // Verify if the document is signed by the authority
        const isSigned = await this.documentNFT.verifySignatures(1, [this.authority.getAddress()]);
        expect(isSigned).to.be.true;
    });
});
