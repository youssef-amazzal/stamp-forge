// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract AuthorityRegistry {
    // Struct to represent an authority
    struct Authority {
        address authorityAddress;
        string name;
    }

    // Mapping from authority address to Authority struct
    mapping(address => Authority) public authorities;

    // Event emitted when a new authority is registered
    event AuthorityRegistered(address indexed authorityAddress, string name);

    // Function to register a new authority
    function registerAuthority(address _authorityAddress, string memory _name) external {
        require(_authorityAddress != address(0), "Invalid address");
        require(bytes(_name).length > 0, "Name must not be empty");
        require(authorities[_authorityAddress].authorityAddress == address(0), "Authority already registered");

        authorities[_authorityAddress] = Authority(_authorityAddress, _name);
        emit AuthorityRegistered(_authorityAddress, _name);
    }

    // Function to get authority details
    function getAuthority(address _authorityAddress) external view returns (Authority memory) {
        return authorities[_authorityAddress];
    }
}
