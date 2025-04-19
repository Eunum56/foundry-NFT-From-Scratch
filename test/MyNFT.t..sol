// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract CounterTest is Test {
    MyNFT public myNFT;

    function setUp() public {
        myNFT = new MyNFT("MyNFT", "MY");
    }

    function testConstructorParams() public view {
        string memory expectedName = "MyNFT";
        string memory expectedSymbol = "MY";
        assertEq(myNFT.name(), expectedName);
        assertEq(myNFT.symbol(), expectedSymbol);
    }
}
