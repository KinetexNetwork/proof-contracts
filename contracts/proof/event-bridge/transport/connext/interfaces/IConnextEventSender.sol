// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IConnext} from "@connext/interfaces/core/IConnext.sol";

import {IBaseEventSender} from "../../base/interfaces/IBaseEventSender.sol";

import {ConnextEventSenderParams} from "./ConnextEventSenderParams.sol";

interface IConnextEventSenderErrors {
    error InvalidConnextAddress();
}

interface IConnextEventSenderViews {
    function CONNEXT() external view returns (IConnext);

    function CONNEXT_RECEIVER_CHAIN() external view returns (uint32);
}

interface IConnextEventSender is IBaseEventSender, IConnextEventSenderErrors, IConnextEventSenderViews {}
