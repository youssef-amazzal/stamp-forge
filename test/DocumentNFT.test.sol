// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "hardhat/console.sol";
import { ethers } from "hardhat";
import { assert } from "chai";

contract TestDocumentNFT {
    AuthorityRegistry authorityRegistry;
    Signature signature;
    DocumentNFT documentNFT;

    function beforeEach() public {
        // Deploy AuthorityRegistry contract
        authorityRegistry = new AuthorityRegistry();

        // Deploy Signature contract
        signature = new Signature();

        // Deploy DocumentNFT contract
        documentNFT = new DocumentNFT(authorityRegistry, signature, "URI");
    }

    function testMintDocumentNFT() public {
        // Mint a document NFT
        documentNFT.mintDocumentNFT(msg.sender, "hash", "type", msg.sender, 123, 456);

        // Retrieve document metadata
        DocumentNFT.DocumentMetadata memory metadata = documentNFT.getDocumentMetadata(1);

        // Assert metadata
        assert.equal(metadata.owner, msg.sender);
        assert.equal(metadata.documentType, "type");
        // Add more assertions for other metadata fields
    }

    function testSignDocument() public {
        // Sign a document
        signature.signDocument(1, "r", "s", 0);

        // Verify if the document is signed by the authority
        bool isSigned = documentNFT.verifySignatures(1, [msg.sender]);
        assert.isTrue(isSigned, "Document should be signed by the authority");
    }
}
