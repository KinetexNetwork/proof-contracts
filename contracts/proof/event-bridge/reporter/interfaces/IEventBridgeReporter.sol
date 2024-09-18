// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

// Send data (`sends`) is grouped into 256-bit words. Each word represents a payment amount
// (in native cryptocurrency) to a bridge sender. First 8 bits represent index of the sender,
// the next 248 - corresponding bits of the native amount.

interface IEventBridgeReporter {
    function reportEvent(bytes32 eventHash, uint256 chain, bytes32[] calldata sends) external;

    function reportEventNative(bytes32 eventHash, uint256 chain, bytes32[] calldata sends) external payable;

    function reportEvents(bytes32[] calldata eventHashes, uint256 chain, bytes32[] calldata sends) external;

    function reportEventsNative(bytes32[] calldata eventHashes, uint256 chain, bytes32[] calldata sends) external payable;
}
