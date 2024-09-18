// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventReceiver} from "../../base/interfaces/IBaseEventReceiver.sol";

import {IMessageReceiverApp, IMessageBus} from "./Celer.sol";
import {CelerEventReceiverParams} from "./CelerEventReceiverParams.sol";

interface ICelerEventReceiverErrors {
    error InvalidCelerBus();
    error UnauthorizedCelerReceive();
}

interface ICelerEventReceiverViews {
    function CELER_BUS() external view returns (IMessageBus);

    function CELER_SENDER_CHAIN() external view returns (uint32);
}

interface ICelerEventReceiver is IBaseEventReceiver, ICelerEventReceiverErrors, ICelerEventReceiverViews, IMessageReceiverApp {}
