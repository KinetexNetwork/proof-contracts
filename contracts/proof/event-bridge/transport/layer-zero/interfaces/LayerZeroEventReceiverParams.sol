// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct LayerZeroEventReceiverParams {
    address eventHashStorage;
    uint256 senderChain;
    address senderAddress;
    address layerZeroEndpoint;
    uint16 layerZeroSenderChain;
}
