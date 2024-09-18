// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventSender} from "../../base/interfaces/IBaseEventSender.sol";

import {IWormholeRelayer} from "./Wormhole.sol";
import {WormholeEventSenderParams} from "./WormholeEventSenderParams.sol";

interface IWormholeEventSenderErrors {
    error InvalidWormholeRelayer();
}

interface IWormholeEventSenderViews {
    function WORMHOLE_CHAIN() external view returns (uint16);

    function WORMHOLE_RELAYER() external view returns (IWormholeRelayer);

    function WORMHOLE_RECEIVER_CHAIN() external view returns (uint16);
}

interface IWormholeEventSender is IBaseEventSender, IWormholeEventSenderErrors, IWormholeEventSenderViews {}
