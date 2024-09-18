// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

import {BaseEventReceiver} from "../base/BaseEventReceiver.sol";

import {IChainlinkEventReceiver, ChainlinkEventReceiverParams, Client} from "./interfaces/IChainlinkEventReceiver.sol";

contract ChainlinkEventReceiver is IChainlinkEventReceiver, BaseEventReceiver, CCIPReceiver {
    string public constant PROVIDER = "chainlink";
    uint64 public immutable CHAINLINK_SENDER_CHAIN;

    // prettier-ignore
    constructor(ChainlinkEventReceiverParams memory params_)
        BaseEventReceiver(params_.eventHashStorage, params_.senderChain, params_.senderAddress) CCIPReceiver(params_.chainlinkRouter) {
        CHAINLINK_SENDER_CHAIN = params_.chainlinkSenderChain;
    }

    function _ccipReceive(Client.Any2EVMMessage memory message_) internal override {
        // prettier-ignore
        if (message_.sourceChainSelector != CHAINLINK_SENDER_CHAIN || abi.decode(message_.sender, (address)) != SENDER_ADDRESS) revert UnauthorizedChainlinkReceive();
        _receivePayload(message_.data);
    }
}
