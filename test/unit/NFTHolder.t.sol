// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {NFTHolder} from "../../src/NFTHolder.sol";

// Interface for the mock ERC721 call in withdrawNFT
interface IERC721Minimal {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract NFTHolderTests is Test {
    NFTHolder nftHolder;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address operator = makeAddr("operator");
    address fakeNFTContract = makeAddr("nftContract");

    event NFTDeposited(address indexed owner, uint256 indexed tokenId);
    event NFTWithdrawn(address indexed owner, uint256 indexed tokenId);

    function setUp() public {
        nftHolder = new NFTHolder();
    }

    // onERC721Received() tests
    function testOnERC721ReceivedReverts() public {
        vm.expectRevert(NFTHolder.NFTHolder__InvalidAddress.selector);
        nftHolder.onERC721Received(address(0), user, 1, "");

        vm.expectRevert(NFTHolder.NFTHolder__InvalidAddress.selector);
        nftHolder.onERC721Received(operator, address(0), 1, "");
    }

    function testOnERC721ReceivedUpdatesOwnerAndBalanceAndEmits() public {
        assertEq(nftHolder.ownerOf(1), address(0));
        assertEq(nftHolder.balanceOf(user), 0);

        vm.expectEmit(true, true, false, false);
        emit NFTDeposited(user, 1);
        nftHolder.onERC721Received(operator, user, 1, "");

        assertEq(nftHolder.ownerOf(1), user);
        assertEq(nftHolder.balanceOf(user), 1);
    }

    // withdrawNFT() tests
    function testWithdrawNFTRevertsIfInvalidAddress() public {
        nftHolder.onERC721Received(operator, user, 1, "");

        vm.prank(user);
        vm.expectRevert(NFTHolder.NFTHolder__InvalidAddress.selector);
        nftHolder.withdrawNFT(address(0), 1);
    }

    function testWithdrawNFTRevertsIfNotOwner() public {
        nftHolder.onERC721Received(operator, user, 1, "");

        vm.prank(owner);
        vm.expectRevert(NFTHolder.NFTHolder__NotOwner.selector);
        nftHolder.withdrawNFT(fakeNFTContract, 1);
    }

    function testWithdrawNFTSuccess() public {
        // Preload token
        nftHolder.onERC721Received(operator, user, 1, "");

        // Mock NFT contract
        vm.mockCall(
            fakeNFTContract,
            abi.encodeWithSelector(IERC721Minimal.safeTransferFrom.selector, address(nftHolder), user, 1),
            abi.encode()
        );

        vm.prank(user);
        vm.expectEmit(true, true, false, false);
        emit NFTWithdrawn(user, 1);
        nftHolder.withdrawNFT(fakeNFTContract, 1);

        assertEq(nftHolder.ownerOf(1), address(0));
        assertEq(nftHolder.balanceOf(user), 0);
    }
}
