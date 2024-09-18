// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

library EventBridgeHashLib {
    function calcEventsHash(bytes32[] calldata eventHashes_) internal pure returns (bytes32) {
        return keccak256(abi.encode(eventHashes_));
    }
}
