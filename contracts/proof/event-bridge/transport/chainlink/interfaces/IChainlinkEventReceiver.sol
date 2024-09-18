// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IAny2EVMMessageReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

import {IBaseEventReceiver} from "../../base/interfaces/IBaseEventReceiver.sol";

import {ChainlinkEventReceiverParams} from "./ChainlinkEventReceiverParams.sol";

interface IChainlinkEventReceiverErrors {
    error UnauthorizedChainlinkReceive();
}

interface IChainlinkEventReceiverViews {
    function CHAINLINK_SENDER_CHAIN() external view returns (uint64);
}

interface IChainlinkEventReceiver is IBaseEventReceiver, IChainlinkEventReceiverErrors, IChainlinkEventReceiverViews, IAny2EVMMessageReceiver {}
