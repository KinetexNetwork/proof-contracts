// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventReceiver} from "../../base/interfaces/IBaseEventReceiver.sol";

import {ZetaReceiver, ZetaInterfaces, ZetaConnector} from "./ZetaChain.sol";
import {ZetaChainEventReceiverParams} from "./ZetaChainEventReceiverParams.sol";

interface IZetaChainEventReceiverErrors {
    error InvalidZetaChainConnector();
    error InvalidZetaChainSenderAddress();
    error UnauthorizedZetaChainReceive();
    error UnauthorizedZetaChainReceiveRevert();
}

interface IZetaChainEventReceiverViews {
    function ZETA_CHAIN_CONNECTOR() external view returns (ZetaConnector);

    function ZETA_CHAIN_SENDER_ADDRESS_HASH() external view returns (bytes32);
}

interface IZetaChainEventReceiver is IBaseEventReceiver, IZetaChainEventReceiverErrors, IZetaChainEventReceiverViews, ZetaReceiver {}
