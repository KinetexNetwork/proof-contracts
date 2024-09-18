// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks

pragma solidity 0.8.24;

import {IEventBridgeRelayer} from "./IEventBridgeRelayer.sol";

interface IEventBridgeRelayerFossilErrors {
    error EventNotReceived();
}

interface IEventBridgeRelayerFossil is IEventBridgeRelayer, IEventBridgeRelayerFossilErrors {}
