// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct ZetaChainEventReceiverParams {
    address eventHashStorage;
    uint256 senderChain;
    address senderAddress;
    address zetaChainConnector;
    bytes zetaChainSenderAddress;
}
