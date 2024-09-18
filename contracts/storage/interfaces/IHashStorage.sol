// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file

pragma solidity 0.8.24;

interface IHashStorageViews {
    function hasHashStore(bytes32 hash) external view returns (bool);
}

interface IHashStorage is IHashStorageViews {
    function storeHash(bytes32 hash) external;
}
