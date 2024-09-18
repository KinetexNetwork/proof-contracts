// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventSender} from "../base/BaseEventSender.sol";

import {ICelerEventSender, CelerEventSenderParams, IMessageBus} from "./interfaces/ICelerEventSender.sol";

contract CelerEventSender is ICelerEventSender, BaseEventSender {
    string public constant PROVIDER = "celer";
    IMessageBus public immutable CELER_BUS;
    uint64 public immutable CELER_RECEIVER_CHAIN;

    constructor(CelerEventSenderParams memory params_) BaseEventSender(params_.publisher, params_.receiverChain, params_.receiverAddress) {
        if (params_.celerBus == address(0)) revert InvalidCelerBus();
        CELER_BUS = IMessageBus(params_.celerBus);
        CELER_RECEIVER_CHAIN = params_.celerReceiverChain;
    }

    function _sendPayload(bytes calldata payload_, address) internal override {
        CELER_BUS.sendMessage{value: msg.value}(RECEIVER_ADDRESS, CELER_RECEIVER_CHAIN, payload_);
    }
}
