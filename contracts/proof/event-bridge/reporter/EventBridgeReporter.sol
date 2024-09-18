// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {LocalStateVerifier} from "../../local-state/LocalStateVerifier.sol";

import {EventBridgeHashLib} from "../EventBridgeHashLib.sol";

import {IEventBridgeReporter} from "./interfaces/IEventBridgeReporter.sol";

import {EventMultiSender} from "./EventMultiSender.sol";

abstract contract EventBridgeReporter is IEventBridgeReporter, LocalStateVerifier, EventMultiSender {
    constructor(address eventHashStorage_, address nativeToken_) LocalStateVerifier(eventHashStorage_) EventMultiSender(nativeToken_) {}

    function reportEvent(bytes32 eventHash_, uint256 chain_, bytes32[] calldata sends_) external {
        _reportEvent(eventHash_, chain_, sends_, false);
    }

    function reportEventNative(bytes32 eventHash_, uint256 chain_, bytes32[] calldata sends_) external payable {
        _reportEvent(eventHash_, chain_, sends_, true);
    }

    function reportEvents(bytes32[] calldata eventHashes_, uint256 chain_, bytes32[] calldata sends_) external {
        _reportEvents(eventHashes_, chain_, sends_, false);
    }

    function reportEventsNative(bytes32[] calldata eventHashes_, uint256 chain_, bytes32[] calldata sends_) external payable {
        _reportEvents(eventHashes_, chain_, sends_, true);
    }

    function _reportEvent(bytes32 eventHash_, uint256 chain_, bytes32[] calldata sends_, bool nativePayment_) private {
        _verifyEventHash(eventHash_);
        _sendPayload(eventHash_, chain_, sends_, nativePayment_);
    }

    function _reportEvents(bytes32[] calldata eventHashes_, uint256 chain_, bytes32[] calldata sends_, bool nativePayment_) private {
        for (uint256 i = 0; i < eventHashes_.length; i++) _verifyEventHash(eventHashes_[i]);
        _sendPayload(EventBridgeHashLib.calcEventsHash(eventHashes_), chain_, sends_, nativePayment_);
    }
}
