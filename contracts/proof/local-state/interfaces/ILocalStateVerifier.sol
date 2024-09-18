// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks, func-name-mixedcase

import {IHashStorageViews} from "../../../storage/interfaces/IHashStorage.sol";

pragma solidity 0.8.24;

interface ILocalStateProofVerifierErrors {
    error InvalidEventHashStorage();
    error EventHashNotStored();
}

interface ILocalStateProofVerifierViews {
    function EVENT_HASH_STORAGE() external view returns (IHashStorageViews);
}

interface ILocalStateVerifier is ILocalStateProofVerifierErrors, ILocalStateProofVerifierViews {}
