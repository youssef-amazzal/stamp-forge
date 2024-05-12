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
        address issuingAuthority;
        uint256 issuingDate;
        uint256 expirationDate;
    }

    // Mapping from token ID to document metadata
    mapping(uint256 => DocumentMetadata) public documents;

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
        address _issuingAuthority, // Changed to address
        uint256 _issuingDate,
        uint256 _expirationDate
    ) external returns (uint256) {
        AuthorityRegistry.Authority memory authority = authorityRegistry.getAuthority(_issuingAuthority);
        require(authority.authorityAddress != address(0), "Invalid authority");
        
        uint256 tokenId = uint256(keccak256(abi.encodePacked(_to, _hash)));
        documents[tokenId] = DocumentMetadata(_hash, _to, _documentType, _issuingAuthority, _issuingDate, _expirationDate);
        _mint(_to, tokenId, 1, "");
        emit DocumentMinted(tokenId, _to);
        return tokenId;
    }

    // Function to sign a document
    function signDocument(uint256 tokenId, bytes32 r, bytes32 s, uint8 v) external {
        signature.signDocument(tokenId, r, s, v);
    }

    // Function to verify if a document is signed by a list of authorities
    function verifySignatures(uint256 tokenId, address[] memory authorities) external view returns (bool) {
        return signature.verifySignatures(tokenId, authorities);
    }

    // Function to get document metadata
    function getDocumentMetadata(uint256 _tokenId) external view returns (DocumentMetadata memory) {
        return documents[_tokenId];
    }
}