// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IERC20Native} from "../../../../native/interfaces/IERC20Native.sol";

interface IEventMultiSenderErrors {
    error InvalidNativeToken();
    error InsufficientMessageValue();
}

interface IEventMultiSenderViews {
    function NATIVE_TOKEN() external view returns (IERC20Native);
}

interface IEventMultiSender is IEventMultiSenderErrors, IEventMultiSenderViews {}
