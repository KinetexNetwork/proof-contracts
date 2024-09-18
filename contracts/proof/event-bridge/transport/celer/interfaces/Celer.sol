// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file

pragma solidity 0.8.24;

interface IMessageBus {
    function sendMessage(address receiver, uint256 dstChainId, bytes calldata message) external payable;
}

interface IMessageReceiverApp {
    enum ExecutionStatus {
        Fail,
        Success,
        Retry
    }

    function executeMessage(address sender, uint64 srcChainId, bytes calldata message, address executor) external payable returns (ExecutionStatus);
}
