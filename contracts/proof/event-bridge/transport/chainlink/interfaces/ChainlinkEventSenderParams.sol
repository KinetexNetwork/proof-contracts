// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct ChainlinkEventSenderParams {
    address publisher;
    uint64 receiverChain;
    address receiverAddress;
    address chainlinkRouter;
    uint64 chainlinkReceiverChain;
}
