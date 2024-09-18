// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventSender} from "../../base/interfaces/IBaseEventSender.sol";

import {ILayerZeroEndpoint} from "./LayerZero.sol";
import {LayerZeroEventSenderParams} from "./LayerZeroEventSenderParams.sol";

interface ILayerZeroEventSenderErrors {
    error InvalidLayerZeroEndpoint();
}

interface ILayerZeroEventSenderViews {
    function LAYER_ZERO_ENDPOINT() external view returns (ILayerZeroEndpoint);

    function LAYER_ZERO_RECEIVER_CHAIN() external view returns (uint16);
}

interface ILayerZeroEventSender is IBaseEventSender, ILayerZeroEventSenderErrors, ILayerZeroEventSenderViews {}
