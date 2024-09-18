// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, func-name-mixedcase

pragma solidity 0.8.24;

import {ISharedHashStorage} from "../../../../../storage/interfaces/ISharedHashStorage.sol";

import {IProviderAware} from "./IProviderAware.sol";

interface IBaseEventReceiverErrors {
    error InvalidEventHashStorage();
    error InvalidSenderChain();
    error InvalidSenderAddress();
    error RestoreHashNotReceived();
    error InvalidEventPayload();
}

interface IBaseEventReceiverViews {
    function EVENT_HASH_STORAGE() external view returns (ISharedHashStorage);

    function SENDER_CHAIN() external view returns (uint256);

    function SENDER_ADDRESS() external view returns (address);
}

interface IBaseEventReceiver is IProviderAware, IBaseEventReceiverErrors, IBaseEventReceiverViews {
    function restoreEventHashes(bytes32[] memory eventHashes) external;
}
