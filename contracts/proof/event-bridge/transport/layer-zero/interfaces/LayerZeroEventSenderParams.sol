// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct LayerZeroEventSenderParams {
    address publisher;
    uint256 receiverChain;
    address receiverAddress;
    address layerZeroEndpoint;
    uint16 layerZeroReceiverChain;
}
