// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventReceiver} from "../base/BaseEventReceiver.sol";

import {IWormholeEventReceiver, WormholeEventReceiverParams, IWormholeRelayer} from "./interfaces/IWormholeEventReceiver.sol";

contract WormholeEventReceiver is IWormholeEventReceiver, BaseEventReceiver {
    string public constant PROVIDER = "wormhole";
    IWormholeRelayer public immutable WORMHOLE_RELAYER;
    uint16 public immutable WORMHOLE_SENDER_CHAIN;
    bytes32 public immutable WORMHOLE_SENDER_ADDRESS;

    constructor(WormholeEventReceiverParams memory params_) BaseEventReceiver(params_.eventHashStorage, params_.senderChain, params_.senderAddress) {
        if (params_.wormholeRelayer == address(0)) revert InvalidWormholeRelayer();
        WORMHOLE_RELAYER = IWormholeRelayer(params_.wormholeRelayer);
        WORMHOLE_SENDER_CHAIN = params_.wormholeSenderChain;
        WORMHOLE_SENDER_ADDRESS = params_.wormholeSenderAddress;
    }

    function receiveWormholeMessages(bytes memory payload_, bytes[] memory, bytes32 sourceAddress_, uint16 sourceChain_, bytes32) external payable {
        // prettier-ignore
        if (msg.sender != address(WORMHOLE_RELAYER) || sourceChain_ != WORMHOLE_SENDER_CHAIN || sourceAddress_ != WORMHOLE_SENDER_ADDRESS) revert UnauthorizedWormholeReceive();
        _receivePayload(payload_);
    }
}
