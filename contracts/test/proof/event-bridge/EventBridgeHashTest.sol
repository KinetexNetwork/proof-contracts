// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {EventBridgeHashLib} from "../../../proof/event-bridge/EventBridgeHashLib.sol";

contract EventBridgeHashTest {
    function calcEventsHash(bytes32[] calldata eventHashes_) external pure returns (bytes32) {
        return EventBridgeHashLib.calcEventsHash(eventHashes_);
    }
}
