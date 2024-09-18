// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct AxelarEventReceiverParams {
    address eventHashStorage;
    uint256 senderChain;
    address senderAddress;
    address axelarGateway;
    string axelarSenderChain;
    string axelarSenderAddress;
}
