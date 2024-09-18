// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct CelerEventSenderParams {
    address publisher;
    uint256 receiverChain;
    address receiverAddress;
    address celerBus;
    uint32 celerReceiverChain;
}
