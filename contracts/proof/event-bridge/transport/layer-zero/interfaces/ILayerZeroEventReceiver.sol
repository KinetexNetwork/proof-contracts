// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventReceiver} from "../../base/interfaces/IBaseEventReceiver.sol";

import {ILayerZeroReceiver, ILayerZeroEndpoint} from "./LayerZero.sol";
import {LayerZeroEventReceiverParams} from "./LayerZeroEventReceiverParams.sol";

interface ILayerZeroEventReceiverErrors {
    error InvalidLayerZeroEndpoint();
    error UnauthorizedLayerZeroReceive();
}

interface ILayerZeroEventReceiverViews {
    function LAYER_ZERO_ENDPOINT() external view returns (ILayerZeroEndpoint);

    function LAYER_ZERO_SENDER_CHAIN() external view returns (uint32);

    function LAYER_ZERO_SENDER_PATH_HASH() external view returns (bytes32);
}

interface ILayerZeroEventReceiver is IBaseEventReceiver, ILayerZeroEventReceiverErrors, ILayerZeroEventReceiverViews, ILayerZeroReceiver {}
