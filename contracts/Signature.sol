// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Signature {
    // Mapping from token ID to authorities' addresses
    mapping(uint256 => mapping(address => bool)) private _signatures;

    // Function to sign a document
    function signDocument(uint256 tokenId, bytes32 r, bytes32 s, uint8 v) external {
        bytes32 hash = keccak256(abi.encodePacked(tokenId));
        address signer = ecrecover(hash, v, r, s);

        require(signer == msg.sender, "Signature does not match the sender");

        _signatures[tokenId][signer] = true;
    }

    // Function to verify if a document is signed by a list of authorities
    function verifySignatures(uint256 tokenId, address[] memory authorities) external view returns (bool) {
        for (uint256 i = 0; i < authorities.length; i++) {
            if (!_signatures[tokenId][authorities[i]]) {
                return false;
            }
        }
        return true;
    }
}