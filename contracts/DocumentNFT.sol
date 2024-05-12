// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "hardhat/console.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./AuthorityRegistry.sol"; // Import Authority contract
import "./Signature.sol"; // Import Signature contract

contract DocumentNFT is ERC1155 {
    AuthorityRegistry public authorityRegistry; // Reference to Authority contract
    Signature public signature; // Reference to Signature contract

    // Struct to represent document metadata
    struct DocumentMetadata {
        bytes32 hash;
        address owner;
        string documentType;
        uint256 issuingDate;
        uint256 expirationDate;
        string fileName;
        string ipfsHash;
    }

    // Mapping from token ID to document metadata
    mapping(uint256 => DocumentMetadata) public documents;

    // Mapping from token ID to authorities' signatures
    mapping(uint256 => mapping(address => bool)) public documentSignatures;

    // Event emitted when a new document NFT is minted
    event DocumentMinted(uint256 indexed tokenId, address indexed owner);

    constructor(AuthorityRegistry _authorityRegistry, Signature _signature, string memory _uri) ERC1155(_uri) {
        authorityRegistry = _authorityRegistry; // Initialize Authority contract reference
        signature = _signature; // Initialize Signature contract reference
    }

    // Function to mint a new document NFT
    function mintDocumentNFT(
        address _to,
        bytes32 _hash,
        string memory _documentType,
        uint256 _issuingDate,
        uint256 _expirationDate,
        string memory _fileName,
        string memory _ipfsHash
    ) external returns (uint256) {
        // Generate a unique token ID using hash and recipient address
        uint256 tokenId = uint256(keccak256(abi.encodePacked(_to, _hash)));

        // Create document metadata struct
        DocumentMetadata memory metadata;
        metadata.hash = _hash;
        metadata.owner = _to;
        metadata.documentType = _documentType;
        metadata.issuingDate = _issuingDate;
        metadata.expirationDate = _expirationDate;
        metadata.fileName = _fileName;
        metadata.ipfsHash = _ipfsHash;

        // Store document metadata
        documents[tokenId] = metadata;

        // Mint the NFT
        _mint(_to, tokenId, 1, "");

        // Emit event
        emit DocumentMinted(tokenId, _to);

        return tokenId;
    }

    // Function to sign a document
    function signDocument(uint256 tokenId) external {
        // Ensure the document exists
        require(documents[tokenId].owner != address(0), "Document does not exist");
        
        // Get the sender's address
        address signer = msg.sender;

        // Check if the signer is a registered authority
        AuthorityRegistry.Authority memory authority = authorityRegistry.getAuthority(signer);
        require(authority.authorityAddress != address(0), "Signer is not a registered authority");

        // Mark the signer as having signed the document
        documentSignatures[tokenId][signer] = true;
    }

    // Function to verify if a document is signed by a list of authorities
    function verifySignatures(uint256 tokenId, address[] memory authorities) external view returns (bool) {
        for (uint256 i = 0; i < authorities.length; i++) {
            if (!documentSignatures[tokenId][authorities[i]]) {
                return false;
            }
        }
        return true;
    }

    // Function to get document metadata
    function getDocumentMetadata(uint256 _tokenId) external view returns (DocumentMetadata memory) {
        return documents[_tokenId];
    }
}