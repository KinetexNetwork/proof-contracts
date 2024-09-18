// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, func-name-mixedcase

pragma solidity 0.8.24;

import {IEventSender} from "../../interfaces/IEventSender.sol";

import {IProviderAware} from "./IProviderAware.sol";

interface IBaseEventSenderErrors {
    error InvalidPublisher();
    error InvalidReceiverChain();
    error InvalidReceiverAddress();
    error UnauthorizedPublisher();
}

interface IBaseEventSenderViews {
    function PUBLISHER() external view returns (address);

    function RECEIVER_CHAIN() external view returns (uint256);

    function RECEIVER_ADDRESS() external view returns (address);
}

interface IBaseEventSender is IEventSender, IProviderAware, IBaseEventSenderErrors, IBaseEventSenderViews {
    function sendPayload(bytes calldata payload, address refundAddress) external payable;
}
