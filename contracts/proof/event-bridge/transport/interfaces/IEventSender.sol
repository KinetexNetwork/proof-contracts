// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

interface IEventSender {
    function sendPayload(bytes calldata payload, address refundAddress) external payable;
}
