// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BitAuthHashStorage} from "../../../storage/BitAuthHashStorage.sol";

import {IEventBridgeAdapterFossil} from "./interfaces/IEventBridgeAdapterFossil.sol";

contract EventBridgeAdapterFossil is IEventBridgeAdapterFossil, BitAuthHashStorage {
    uint8 public immutable THRESHOLD;

    constructor(address[] memory writers_, uint8 threshold_) BitAuthHashStorage(writers_) {
        if (threshold_ > writers_.length) revert ThresholdTooHigh();
        THRESHOLD = threshold_;
    }

    function eventReceived(bytes32 eventHash_) public view returns (bool) {
        return hashStoreCount(eventHash_) >= THRESHOLD;
    }
}
