// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IBaseEventSender} from "./interfaces/IBaseEventSender.sol";

abstract contract BaseEventSender is IBaseEventSender {
    address public immutable PUBLISHER;
    uint256 public immutable RECEIVER_CHAIN;
    address public immutable RECEIVER_ADDRESS;

    constructor(address publisher_, uint256 receiverChain_, address receiverAddress_) {
        if (publisher_ == address(0)) revert InvalidPublisher();
        if (receiverChain_ == 0) revert InvalidReceiverChain();
        if (receiverAddress_ == address(0)) revert InvalidReceiverAddress();
        PUBLISHER = publisher_;
        RECEIVER_CHAIN = receiverChain_;
        RECEIVER_ADDRESS = receiverAddress_;
    }

    function sendPayload(bytes calldata payload_, address refundAddress_) external payable {
        if (msg.sender != PUBLISHER) revert UnauthorizedPublisher();
        _sendPayload(payload_, refundAddress_);
    }

    function _sendPayload(bytes calldata payload_, address refundAddress_) internal virtual;
}
