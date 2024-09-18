// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventSender} from "../../base/interfaces/IBaseEventSender.sol";

import {IMessageBus} from "./Celer.sol";
import {CelerEventSenderParams} from "./CelerEventSenderParams.sol";

interface ICelerEventSenderErrors {
    error InvalidCelerBus();
}

interface ICelerEventSenderViews {
    function CELER_BUS() external view returns (IMessageBus);

    function CELER_RECEIVER_CHAIN() external view returns (uint64);
}

interface ICelerEventSender is IBaseEventSender, ICelerEventSenderErrors, ICelerEventSenderViews {}
