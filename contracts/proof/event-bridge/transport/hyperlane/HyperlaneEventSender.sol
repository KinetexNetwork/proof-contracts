// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventSender} from "../base/BaseEventSender.sol";

import {IHyperlaneEventSender, HyperlaneEventSenderParams, IMailbox} from "./interfaces/IHyperlaneEventSender.sol";

contract HyperlaneEventSender is IHyperlaneEventSender, BaseEventSender {
    string public constant PROVIDER = "hyperlane";
    IMailbox public immutable HYPERLANE_MAILBOX;
    uint32 public immutable HYPERLANE_RECEIVER_CHAIN;
    bytes32 public immutable HYPERLANE_RECEIVER_ADDRESS;

    constructor(HyperlaneEventSenderParams memory params_) BaseEventSender(params_.publisher, params_.receiverChain, params_.receiverAddress) {
        if (params_.hyperlaneMailbox == address(0)) revert InvalidHyperlaneMailbox();
        HYPERLANE_MAILBOX = IMailbox(params_.hyperlaneMailbox);
        HYPERLANE_RECEIVER_CHAIN = params_.hyperlaneReceiverChain;
        HYPERLANE_RECEIVER_ADDRESS = params_.hyperlaneReceiverAddress;
    }

    function _sendPayload(bytes calldata payload_, address) internal override {
        HYPERLANE_MAILBOX.dispatch{value: msg.value}(HYPERLANE_RECEIVER_CHAIN, HYPERLANE_RECEIVER_ADDRESS, payload_);
    }
}
