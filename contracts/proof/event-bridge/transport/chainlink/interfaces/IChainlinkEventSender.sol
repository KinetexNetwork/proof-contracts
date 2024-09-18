// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

import {IBaseEventSender} from "../../base/interfaces/IBaseEventSender.sol";

import {ChainlinkEventSenderParams} from "./ChainlinkEventSenderParams.sol";

interface IChainlinkEventSenderErrors {
    error InvalidChainlinkRouter();
}

interface IChainlinkEventSenderViews {
    function CHAINLINK_ROUTER() external view returns (IRouterClient);

    function CHAINLINK_RECEIVER_CHAIN() external view returns (uint64);
}

interface IChainlinkEventSender is IBaseEventSender, IChainlinkEventSenderErrors, IChainlinkEventSenderViews {}
