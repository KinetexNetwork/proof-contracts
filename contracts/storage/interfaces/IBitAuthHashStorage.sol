// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks

pragma solidity 0.8.24;

import {ISharedHashStorage} from "./ISharedHashStorage.sol";
import {IBitAuth} from "./IBitAuth.sol";

interface IBitAuthHashStorageErrors {
    error UnauthorizedStore(address writer);
}

interface IBitAuthHashStorageViews {
    function hashReport(bytes32 hash) external view returns (uint256);
}

interface IBitAuthHashStorage is ISharedHashStorage, IBitAuth, IBitAuthHashStorageErrors, IBitAuthHashStorageViews {}
