// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.24;

import {IERC721} from "./Interfaces/Interfaces.sol";
import {IERC721Receiver} from "./Interfaces/Interfaces.sol";

contract NFTHolder {
    // ERRORS
    error NFTHolder__NotOwner();
    error NFTHolder__InvalidAddress();

    // STATE VARIBALES
    mapping(uint256 tokenId => address owner) private s_owner;
    mapping(address account => uint256 NFTHoldings) private s_balances;

    // EVENTS
    event NFTDeposited(address indexed owner, uint256 indexed tokenId);
    event NFTWithdrawn(address indexed owner, uint256 indexed tokenId);

    // MODIFIERS

    // FUNCTIONS
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        s_owner[tokenId] = from;
        unchecked {
            s_balances[from] += 1;
        }
        emit NFTDeposited(from, tokenId);
        return this.onERC721Received.selector;
    }

    function withdrawNFT(address toContract, uint256 tokenId) external {
        require(toContract != address(0), NFTHolder__InvalidAddress());
        require(s_owner[tokenId] == msg.sender, NFTHolder__NotOwner());
        unchecked {
            s_balances[msg.sender] -= 1;
        }

        IERC721(toContract).safeTransferFrom(address(this), msg.sender, tokenId);
        delete s_owner[tokenId];
        emit NFTWithdrawn(msg.sender, tokenId);
    }
}
