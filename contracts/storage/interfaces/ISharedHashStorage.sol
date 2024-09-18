// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks

pragma solidity 0.8.24;

import {IHashStorage} from "./IHashStorage.sol";

interface ISharedHashStorageAccessViews {
    function canStore(address account) external view returns (bool);
}

interface ISharedHashStorageViews {
    function isHashStoredBy(bytes32 hash, address account) external view returns (bool);

    function hashStoreCount(bytes32 hash) external view returns (uint256);
}

interface ISharedHashStorage is IHashStorage, ISharedHashStorageAccessViews, ISharedHashStorageViews {}
