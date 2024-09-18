// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventReceiver} from "../../base/interfaces/IBaseEventReceiver.sol";

import {IWormholeRelayer} from "./Wormhole.sol";
import {IWormholeReceiver} from "./Wormhole.sol";
import {WormholeEventReceiverParams} from "./WormholeEventReceiverParams.sol";

interface IWormholeEventReceiverErrors {
    error InvalidWormholeRelayer();
    error UnauthorizedWormholeReceive();
}

interface IWormholeEventReceiverViews {
    function WORMHOLE_RELAYER() external view returns (IWormholeRelayer);

    function WORMHOLE_SENDER_CHAIN() external view returns (uint16);

    function WORMHOLE_SENDER_ADDRESS() external view returns (bytes32);
}

interface IWormholeEventReceiver is IBaseEventReceiver, IWormholeEventReceiverErrors, IWormholeEventReceiverViews, IWormholeReceiver {}
