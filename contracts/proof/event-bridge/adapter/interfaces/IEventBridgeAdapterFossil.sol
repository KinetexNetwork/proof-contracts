// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IEventBridgeAdapter} from "./IEventBridgeAdapter.sol";

interface IEventBridgeAdapterFossilErrors {
    error ThresholdTooHigh();
}

interface IEventBridgeAdapterFossilViews {
    function THRESHOLD() external view returns (uint8);
}

interface IEventBridgeAdapterFossil is IEventBridgeAdapter, IEventBridgeAdapterFossilErrors, IEventBridgeAdapterFossilViews {}
