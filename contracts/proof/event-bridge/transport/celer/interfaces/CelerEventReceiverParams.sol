// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct CelerEventReceiverParams {
    address eventHashStorage;
    uint256 senderChain;
    address senderAddress;
    address celerBus;
    uint32 celerSenderChain;
}
