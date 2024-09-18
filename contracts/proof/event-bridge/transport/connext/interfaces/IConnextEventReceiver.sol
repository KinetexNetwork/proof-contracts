// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IConnext} from "@connext/interfaces/core/IConnext.sol";
import {IXReceiver} from "@connext/interfaces/core/IXReceiver.sol";

import {IBaseEventReceiver} from "../../base/interfaces/IBaseEventReceiver.sol";

import {ConnextEventReceiverParams} from "./ConnextEventReceiverParams.sol";

interface IConnextEventReceiverErrors {
    error InvalidConnextAddress();
    error UnauthorizedConnextReceive();
}

interface IConnextEventReceiverViews {
    function CONNEXT() external view returns (IConnext);

    function CONNEXT_SENDER_CHAIN() external view returns (uint32);
}

interface IConnextEventReceiver is IBaseEventReceiver, IConnextEventReceiverErrors, IConnextEventReceiverViews, IXReceiver {}
