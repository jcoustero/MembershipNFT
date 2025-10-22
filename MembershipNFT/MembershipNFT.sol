// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title MembershipNFT
/// @notice NFT representing subscription membership; supports renewals, expiring, and transfer restrictions.
contract MembershipNFT {
    string public name = "MemberPass";
    string public symbol = "MPASS";
    uint256 public totalSupply;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => uint256) public expiresAt;
    mapping(address => uint256) public activeTokenOf;
    uint256 public duration; // seconds
    address public owner;

    event Mint(address indexed to, uint256 indexed id, uint256 expiresAt);
    event Renew(uint256 indexed id, uint256 newExpiry);

    constructor(uint256 _duration) {
        owner = msg.sender;
        duration = _duration;
    }

    function mint() external payable {
        uint256 id = totalSupply + 1;
        totalSupply = id;
        ownerOf[id] = msg.sender;
        expiresAt[id] = block.timestamp + duration;
        activeTokenOf[msg.sender] = id;
        emit Mint(msg.sender, id, expiresAt[id]);
    }

    function renew(uint256 id) external payable {
        require(ownerOf[id] == msg.sender, "not owner");
        expiresAt[id] += duration;
        emit Renew(id, expiresAt[id]);
    }

    // disallow transfers if membership still active (to avoid trading while active)
    function transferFrom(address from, address to, uint256 id) external {
        require(ownerOf[id] == from, "not owner");
        require(block.timestamp > expiresAt[id], "active membership");
        ownerOf[id] = to;
        if(activeTokenOf[from] == id) activeTokenOf[from] = 0;
    }
}
