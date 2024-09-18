// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct ConnextEventSenderParams {
    address publisher;
    uint256 receiverChain;
    address receiverAddress;
    address connext;
    uint32 connextReceiverChain;
}
