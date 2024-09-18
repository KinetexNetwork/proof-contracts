// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct HyperlaneEventSenderParams {
    address publisher;
    uint256 receiverChain;
    address receiverAddress;
    address hyperlaneMailbox;
    uint32 hyperlaneReceiverChain;
    bytes32 hyperlaneReceiverAddress;
}
