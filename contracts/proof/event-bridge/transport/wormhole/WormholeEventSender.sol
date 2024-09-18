// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventSender} from "../base/BaseEventSender.sol";

import {IWormholeEventSender, WormholeEventSenderParams, IWormholeRelayer} from "./interfaces/IWormholeEventSender.sol";

contract WormholeEventSender is IWormholeEventSender, BaseEventSender {
    string public constant PROVIDER = "wormhole";
    uint16 public immutable WORMHOLE_CHAIN;
    IWormholeRelayer public immutable WORMHOLE_RELAYER;
    uint16 public immutable WORMHOLE_RECEIVER_CHAIN;

    constructor(WormholeEventSenderParams memory params_) BaseEventSender(params_.publisher, params_.receiverChain, params_.receiverAddress) {
        if (params_.wormholeRelayer == address(0)) revert InvalidWormholeRelayer();
        WORMHOLE_CHAIN = params_.wormholeChain;
        WORMHOLE_RELAYER = IWormholeRelayer(params_.wormholeRelayer);
        WORMHOLE_RECEIVER_CHAIN = params_.wormholeReceiverChain;
    }

    function _sendPayload(bytes calldata payload_, address refundAddress_) internal override {
        WORMHOLE_RELAYER.sendPayloadToEvm{value: msg.value}(WORMHOLE_RECEIVER_CHAIN, RECEIVER_ADDRESS, payload_, 0, 100_000, WORMHOLE_CHAIN, refundAddress_);
    }
}
