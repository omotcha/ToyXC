// SPDX-License-Identifier: MIT
// a mod to ERC998, minimize the depth of "composable tree" to 2: composable as father and ERC721s as children
pragma solidity ^0.8.9;

interface IERC721FlatComposable {
    event ReceiveChild(address indexed from, uint256 indexed tokenID, address indexed childContract, uint256 childTokenID);
    event TransferChild(uint256 indexed tokenID, address indexed to, address indexed childContract, uint256 childTokenID);

    // nothing
}