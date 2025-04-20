// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract MyNFTTest is Test {

    // EVENTS
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    MyNFT public myNFT;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address user2 = makeAddr("user2");
    address operator = makeAddr("operator");

    function setUp() public {
        myNFT = new MyNFT("MyNFT", "MY");
    }

    function testConstructorParams() public view {
        string memory expectedName = "MyNFT";
        string memory expectedSymbol = "MY";
        assertEq(myNFT.name(), expectedName);
        assertEq(myNFT.symbol(), expectedSymbol);
    }

    // Mint() function tests
    function testMintReverts() public {
        vm.prank(owner);
        myNFT.mint(0);
        vm.prank(user);
        vm.expectRevert(MyNFT.MyNFT__AlreadyMinted.selector);
        myNFT.mint(0);


        for(uint tokenId = 1; tokenId < 1000; tokenId++) {
            vm.prank(owner);
            myNFT.mint(tokenId);
        }
        // console.log(myNFT.totalSupply());
        vm.expectRevert(MyNFT.MyNFT__MaxSupplyExceeds.selector);
        myNFT.mint(1001);
    }

    function testMintUpdateNFTToUser() public {
        vm.prank(owner);
        myNFT.mint(0);
        assertEq(myNFT.ownerOf(0), address(owner));
        assertEq(myNFT.balanceOf(owner), 1);
        assertEq(myNFT.totalSupply(), 1);
    }

    function testMintEmitEvent() public {
        vm.prank(owner);
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0), address(owner), 0);
        myNFT.mint(0);
    }

    // TransferFrom() function tests
    function testTransferFromReverts() public {
        vm.prank(owner);
        myNFT.mint(0);

        vm.expectRevert(MyNFT.MyNFT__InvalidAddress.selector);
        myNFT.transferFrom(address(0), user, 0);

        vm.expectRevert(MyNFT.MyNFT__InvalidAddress.selector);
        myNFT.transferFrom(owner, address(0), 0);

        vm.expectRevert(MyNFT.MyNFT__InvalidTokenId.selector);
        myNFT.transferFrom(owner, user, 1001);

        vm.expectRevert(MyNFT.MyNFT__NotOwnerOfThisNFT.selector);
        myNFT.transferFrom(user, owner, 0);


        // when owner is from
        vm.expectRevert(MyNFT.MyNFT__NotAuthorized.selector);
        myNFT.transferFrom(owner, user, 0);

        // when owner approve user
        vm.prank(owner);
        myNFT.approve(user, 0);

        vm.expectRevert(MyNFT.MyNFT__NotAuthorized.selector);
        myNFT.transferFrom(owner, user, 0);

        // when owner approve operator
        vm.prank(owner);
        myNFT.setApprovalForAll(operator, true);

        vm.expectRevert(MyNFT.MyNFT__NotAuthorized.selector);
        myNFT.transferFrom(owner, user, 0);
    }

    function testTransferFromUpdatesBalances() public {
        vm.prank(owner);
        myNFT.mint(0);

        uint256 ownerNFTBalanceBefore = myNFT.balanceOf(owner);
        uint256 userNFTBalanceBefore = myNFT.balanceOf(user);

        assertEq(ownerNFTBalanceBefore, 1);
        assertEq(userNFTBalanceBefore, 0);

        vm.prank(owner);
        myNFT.transferFrom(owner, user, 0);

        uint256 ownerNFTBalanceAfter = myNFT.balanceOf(owner);
        uint256 userNFTBalanceAfter = myNFT.balanceOf(user);  

        assertEq(ownerNFTBalanceAfter, 0);
        assertEq(userNFTBalanceAfter, 1);

        assertEq(myNFT.ownerOf(0), user);
    }

    function testTransferFromDeleteApprovalsAndEmitEvent() public {
        vm.prank(owner);
        myNFT.mint(0);

        vm.prank(owner);
        myNFT.approve(user, 0);

        assertEq(myNFT.getApproved(0), user);

        vm.prank(owner);
        vm.expectEmit(true, true, true, false);
        emit Transfer(owner, user, 0);
        myNFT.transferFrom(owner, user, 0);

        assertEq(myNFT.getApproved(0), address(0));
    }


    // Approve() function tests
    function testApproveReverts() public {
        vm.prank(owner);
        myNFT.mint(0);

        vm.prank(owner);
        vm.expectRevert(MyNFT.MyNFT__InvalidAddress.selector);
        myNFT.approve(address(0), 0);

        vm.prank(owner);
        vm.expectRevert(MyNFT.MyNFT__InvalidTokenId.selector);
        myNFT.approve(user, 2);

        vm.expectRevert(MyNFT.MyNFT__NotOwnerOfThisNFT.selector);
        myNFT.approve(user, 0);
    }

    function testApproveUpdateValuesAndEmitEvents() public {
        vm.prank(owner);
        myNFT.mint(0);

        assertEq(myNFT.getApproved(0), address(0));

        vm.prank(owner);
        vm.expectEmit(true, true, true, false);
        emit Approval(owner, user, 0);
        myNFT.approve(user, 0);

        assertEq(myNFT.getApproved(0), user);
    }

    // SetOperatorForAll() function tests
    function testSetOperatorForAllReverts() public {
        vm.prank(owner);
        myNFT.mint(0);

        vm.prank(owner);
        vm.expectRevert(MyNFT.MyNFT__InvalidAddress.selector);
        myNFT.setApprovalForAll(address(0), true);
    }

    function testSetOperatorForAllUpdateValueAndEmitEvent() public {
        vm.prank(owner);
        myNFT.mint(0);

        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit ApprovalForAll(owner, operator, true);
        myNFT.setApprovalForAll(operator, true);

        assertEq(myNFT.isApprovedForAll(owner, operator), true);

        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit ApprovalForAll(owner, operator, false);
        myNFT.setApprovalForAll(operator, false);

        assertEq(myNFT.isApprovedForAll(owner, operator), false);
    }

    // BalanceOf() function tests
    function testBalanceOfReverts() public {
        vm.expectRevert(MyNFT.MyNFT__InvalidAddress.selector);
        myNFT.balanceOf(address(0));
    }

    function testBalanceOfRetrunStatement() public view {
        uint256 returnedStatement = myNFT.balanceOf(owner);
        uint256 expectedReturnStatement = 0;

        assertEq(returnedStatement, expectedReturnStatement);
    }

    // OwnerOf() function tests
    function testOwnerOfReverts() public {
        vm.expectRevert(MyNFT.MyNFT__InvalidTokenId.selector);
        myNFT.ownerOf(1000);
    }

    function testOwnerReturnStatement() public {
        vm.prank(owner);
        myNFT.mint(0);

        address returnedStatement = myNFT.ownerOf(0);
        
        assertEq(returnedStatement, owner);
    }

    // GetApproved() function tests
    function testgetApprovedReverts() public {
        vm.expectRevert(MyNFT.MyNFT__InvalidTokenId.selector);
        myNFT.getApproved(1001);
    }

    function testgetApprovedReturnStatement() public  {
        vm.startPrank(owner);
        myNFT.mint(0);
        myNFT.approve(user, 0);
        vm.stopPrank();

        address returnedStatement = myNFT.getApproved(0);

        assertEq(returnedStatement, user);
    }

    // IsApprovedForAll() function tests
    function testIsApprovedForAllReverts() public {
        vm.expectRevert(MyNFT.MyNFT__InvalidAddress.selector);
        myNFT.isApprovedForAll(address(0), user);

        vm.expectRevert(MyNFT.MyNFT__InvalidAddress.selector);
        myNFT.isApprovedForAll(owner, address(0));
    }

    function testIsApprovedForAllReturnStatement() public {
        vm.startPrank(owner);
        myNFT.mint(0);
        myNFT.setApprovalForAll(operator, true);
        vm.stopPrank();

        bool returnedStatement = myNFT.isApprovedForAll(owner, operator);
        assertEq(returnedStatement, true);

        vm.prank(owner);
        myNFT.setApprovalForAll(operator, false);
        bool falseReturnedStatement = myNFT.isApprovedForAll(owner, operator);
        assertEq(falseReturnedStatement, false);
    }

    // TokenURI() function tests
    function testTokenURIReverts() public {
        vm.expectRevert(MyNFT.MyNFT__InvalidTokenId.selector);
        myNFT.tokenURI(1001);
    }


    function testTokenURIRetrunStatement() public view {
    string memory expectedReturnedStatement = "ipfs://haDFlhoeuhhwiuhiHKHDeh93892DH/0";

    string memory returnedStatement = myNFT.tokenURI(0);

    assertEq(returnedStatement, expectedReturnedStatement);

    }
}
