// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RevertingReceiver {
    fallback() external payable {
        revert("Receiver fails");
    }
}
