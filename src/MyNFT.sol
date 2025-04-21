// SPDX-License-Identifier:MIT

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

contract MyNFT {
    // ERRORS
    error MyNFT__InvalidAddress();
    error MyNFT__InvalidTokenId();
    error MyNFT__MaxSupplyExceeds();
    error MyNFT__AlreadyMinted();
    error MyNFT__NotOwnerOfThisNFT();
    error MyNFT__NotAuthorized();

    // STATE VARIABLES
    uint256 private constant MAX_SUPPLY = 1000;
    uint256 private s_NFTCounter = 0;
    string private s_name;
    string private s_symbol;
    string private s_baseURI = "ipfs://haDFlhoeuhhwiuhiHKHDeh93892DH/";
    address private immutable i_owner;
    mapping(address account => uint256 NFTOwned) private s_balances;
    mapping(uint256 tokenId => address owner) private s_owner;
    mapping(uint256 tokenId => address approved) private s_tokenApprovals;
    mapping(address owner => mapping(address operator => bool approved)) private s_operatorApprovals;

    // EVENTS
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    // MODIFIERS

    // FUNCTIONS
    constructor(string memory _name, string memory _symbol) {
        s_name = _name;
        s_symbol = _symbol;
        i_owner = msg.sender;
    }

    // EXTERNAL FUNCTIONS
    function mint(uint256 tokenId) external {
        require(s_NFTCounter < MAX_SUPPLY, MyNFT__MaxSupplyExceeds());
        require(s_owner[tokenId] == address(0), MyNFT__AlreadyMinted());
        _mint(tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(_from != address(0) && _to != address(0), MyNFT__InvalidAddress());
        require(_tokenId < MAX_SUPPLY, MyNFT__InvalidTokenId());
        require(s_owner[_tokenId] == _from, MyNFT__NotOwnerOfThisNFT());
        require(
            _from == msg.sender || s_tokenApprovals[_tokenId] == msg.sender || s_operatorApprovals[_from][msg.sender],
            MyNFT__NotAuthorized()
        );
        _transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external {
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function approve(address _approved, uint256 _tokenId) external {
        require(_approved != address(0), MyNFT__InvalidAddress());
        require(s_owner[_tokenId] != address(0), MyNFT__InvalidTokenId());
        require(s_owner[_tokenId] == msg.sender, MyNFT__NotOwnerOfThisNFT());
        _approve(_approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0), MyNFT__InvalidAddress());
        s_operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function exposeUintToString(uint256 val) external pure returns (string memory) {
        return uintToString(val);
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS

    // PRIVATE FUNCTIONS
    function _mint(uint256 tokenId) private {
        s_owner[tokenId] = msg.sender;
        s_balances[msg.sender] += 1;
        emit Transfer(address(0), msg.sender, tokenId);
        s_NFTCounter++;
    }

    function _approve(address _approved, uint256 _tokenId) private {
        s_tokenApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) private {
        s_owner[_tokenId] = _to;
        unchecked {
            s_balances[_from] -= 1;
            s_balances[_to] += 1;
        }
        delete s_tokenApprovals[_tokenId];
        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) private {
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "MyNFT: Transfer to non-ERC721 receiver");
        _transferFrom(_from, _to, _tokenId);
    }

    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data)
        private
        returns (bool)
    {
        if (_to.code.length > 0) {
            try IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                return false;
            }
        }
        return true;
    }

    function uintToString(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + (_value % 10))); // ASCII '0' = 48
            _value /= 10;
        }
        return string(buffer);
    }

    // VIEW / PURE FUNCTIONS
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), MyNFT__InvalidAddress());
        return s_balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        require(s_owner[_tokenId] != address(0), MyNFT__InvalidTokenId());
        return s_owner[_tokenId];
    }

    function name() external view returns (string memory) {
        return s_name;
    }

    function symbol() external view returns (string memory) {
        return s_symbol;
    }

    function totalSupply() external view returns (uint256) {
        return s_NFTCounter;
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        require(_tokenId < MAX_SUPPLY, MyNFT__InvalidTokenId());
        return s_tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        require(_owner != address(0) && _operator != address(0), MyNFT__InvalidAddress());
        return s_operatorApprovals[_owner][_operator];
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_tokenId < MAX_SUPPLY, MyNFT__InvalidTokenId());
        return string(abi.encodePacked(s_baseURI, uintToString(_tokenId)));
    }
}
