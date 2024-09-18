// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IEventSender} from "../../../proof/event-bridge/transport/interfaces/IEventSender.sol";

contract EventBridgeSenderMock is IEventSender {
    error PayloadAlreadySent();
    error UnexpectedPayload(bytes payload, bytes expectedPayload);
    error UnexpectedValue(uint256 value, uint256 expectedValue);

    bytes private _expectedPayload;
    uint256 private _expectedValue;
    bool public payloadSent;

    function sendPayload(bytes calldata payload_, address) external payable override {
        if (payloadSent) revert PayloadAlreadySent();
        if (keccak256(payload_) != keccak256(_expectedPayload)) revert UnexpectedPayload(payload_, _expectedPayload);
        if (msg.value != _expectedValue) revert UnexpectedValue(msg.value, _expectedValue);
        payloadSent = true;
    }

    function setExpectedPayload(bytes calldata expectedPayload_) external {
        _expectedPayload = expectedPayload_;
    }

    function setExpectedValue(uint256 value_) external {
        _expectedValue = value_;
    }
}
