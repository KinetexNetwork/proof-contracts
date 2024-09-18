// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct WormholeEventSenderParams {
    address publisher;
    uint256 receiverChain;
    address receiverAddress;
    uint16 wormholeChain;
    address wormholeRelayer;
    uint16 wormholeReceiverChain;
}
