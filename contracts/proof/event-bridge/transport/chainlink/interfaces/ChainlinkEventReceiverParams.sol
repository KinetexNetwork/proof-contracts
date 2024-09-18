// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct ChainlinkEventReceiverParams {
    address eventHashStorage;
    uint256 senderChain;
    address senderAddress;
    address chainlinkRouter;
    uint64 chainlinkSenderChain;
}
