// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventSender} from "../base/BaseEventSender.sol";

import {ILayerZeroEventSender, LayerZeroEventSenderParams, ILayerZeroEndpoint} from "./interfaces/ILayerZeroEventSender.sol";

contract LayerZeroEventSender is ILayerZeroEventSender, BaseEventSender {
    string public constant PROVIDER = "layer-zero";
    ILayerZeroEndpoint public immutable LAYER_ZERO_ENDPOINT;
    uint16 public immutable LAYER_ZERO_RECEIVER_CHAIN;

    constructor(LayerZeroEventSenderParams memory params_) BaseEventSender(params_.publisher, params_.receiverChain, params_.receiverAddress) {
        if (params_.layerZeroEndpoint == address(0)) revert InvalidLayerZeroEndpoint();
        LAYER_ZERO_ENDPOINT = ILayerZeroEndpoint(params_.layerZeroEndpoint);
        LAYER_ZERO_RECEIVER_CHAIN = params_.layerZeroReceiverChain;
    }

    function _sendPayload(bytes calldata payload_, address refundAddress_) internal override {
        bytes memory path = abi.encodePacked(RECEIVER_ADDRESS, address(this));
        // solhint-disable-next-line check-send-result
        LAYER_ZERO_ENDPOINT.send{value: msg.value}(LAYER_ZERO_RECEIVER_CHAIN, path, payload_, payable(refundAddress_), address(0), bytes(""));
    }
}
