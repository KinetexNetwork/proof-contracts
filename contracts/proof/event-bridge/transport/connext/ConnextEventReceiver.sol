// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventReceiver} from "../base/BaseEventReceiver.sol";

import {IConnextEventReceiver, ConnextEventReceiverParams, IConnext} from "./interfaces/IConnextEventReceiver.sol";

contract ConnextEventReceiver is IConnextEventReceiver, BaseEventReceiver {
    string public constant PROVIDER = "connext";
    IConnext public immutable CONNEXT;
    uint32 public immutable CONNEXT_SENDER_CHAIN;

    constructor(ConnextEventReceiverParams memory params_) BaseEventReceiver(params_.eventHashStorage, params_.senderChain, params_.senderAddress) {
        if (params_.connext == address(0)) revert InvalidConnextAddress();
        CONNEXT = IConnext(params_.connext);
        CONNEXT_SENDER_CHAIN = params_.connextSenderChain;
    }

    function xReceive(bytes32, uint256, address, address originSender_, uint32 origin_, bytes calldata callData_) external returns (bytes memory) {
        if (msg.sender != address(CONNEXT) || origin_ != CONNEXT_SENDER_CHAIN || originSender_ != SENDER_ADDRESS) revert UnauthorizedConnextReceive();
        _receivePayload(callData_);
        return "";
    }
}
