// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct HyperlaneEventReceiverParams {
    address eventHashStorage;
    uint256 senderChain;
    address senderAddress;
    address hyperlaneMailbox;
    address hyperlaneIsm;
    uint32 hyperlaneSenderChain;
    bytes32 hyperlaneSenderAddress;
}
