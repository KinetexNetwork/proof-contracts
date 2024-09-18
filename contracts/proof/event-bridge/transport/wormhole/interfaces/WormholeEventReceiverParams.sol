// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct WormholeEventReceiverParams {
    address eventHashStorage;
    uint256 senderChain;
    address senderAddress;
    address wormholeRelayer;
    uint16 wormholeSenderChain;
    bytes32 wormholeSenderAddress;
}
