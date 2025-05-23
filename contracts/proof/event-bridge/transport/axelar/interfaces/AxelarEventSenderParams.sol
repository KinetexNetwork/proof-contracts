// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct AxelarEventSenderParams {
    address publisher;
    uint256 receiverChain;
    address receiverAddress;
    address axelarGateway;
    address axelarGasService;
    string axelarReceiverChain;
    string axelarReceiverAddress;
}
