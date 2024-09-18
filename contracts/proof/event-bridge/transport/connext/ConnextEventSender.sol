// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventSender} from "../base/BaseEventSender.sol";

import {IConnextEventSender, ConnextEventSenderParams, IConnext} from "./interfaces/IConnextEventSender.sol";

contract ConnextEventSender is IConnextEventSender, BaseEventSender {
    string public constant PROVIDER = "connext";
    IConnext public immutable CONNEXT;
    uint32 public immutable CONNEXT_RECEIVER_CHAIN;

    constructor(ConnextEventSenderParams memory params_) BaseEventSender(params_.publisher, params_.receiverChain, params_.receiverAddress) {
        if (params_.connext == address(0)) revert InvalidConnextAddress();
        CONNEXT = IConnext(params_.connext);
        CONNEXT_RECEIVER_CHAIN = params_.connextReceiverChain;
    }

    function _sendPayload(bytes calldata payload_, address) internal override {
        CONNEXT.xcall{value: msg.value}(CONNEXT_RECEIVER_CHAIN, RECEIVER_ADDRESS, address(0), address(0), 0, 0, payload_);
    }
}
