// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventReceiver} from "../base/BaseEventReceiver.sol";

import {ILayerZeroEventReceiver, LayerZeroEventReceiverParams, ILayerZeroEndpoint} from "./interfaces/ILayerZeroEventReceiver.sol";

contract LayerZeroEventReceiver is ILayerZeroEventReceiver, BaseEventReceiver {
    string public constant PROVIDER = "layer-zero";
    ILayerZeroEndpoint public immutable LAYER_ZERO_ENDPOINT;
    uint32 public immutable LAYER_ZERO_SENDER_CHAIN;
    bytes32 public immutable LAYER_ZERO_SENDER_PATH_HASH;

    constructor(LayerZeroEventReceiverParams memory params_) BaseEventReceiver(params_.eventHashStorage, params_.senderChain, params_.senderAddress) {
        if (params_.layerZeroEndpoint == address(0)) revert InvalidLayerZeroEndpoint();
        LAYER_ZERO_ENDPOINT = ILayerZeroEndpoint(params_.layerZeroEndpoint);
        LAYER_ZERO_SENDER_CHAIN = params_.layerZeroSenderChain;
        LAYER_ZERO_SENDER_PATH_HASH = keccak256(abi.encodePacked(params_.senderAddress, address(this)));
    }

    function lzReceive(uint16 srcChainId_, bytes memory srcAddress_, uint64, bytes calldata payload_) external {
        // prettier-ignore
        if (msg.sender != address(LAYER_ZERO_ENDPOINT) || srcChainId_ != LAYER_ZERO_SENDER_CHAIN || keccak256(srcAddress_) != LAYER_ZERO_SENDER_PATH_HASH) revert UnauthorizedLayerZeroReceive();
        _receivePayload(payload_);
    }
}
