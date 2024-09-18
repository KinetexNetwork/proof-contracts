// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {ISharedHashStorageAccessViews} from "../interfaces/ISharedHashStorage.sol";

interface IBitAuthErrors {
    error WriterListTooLarge();
    error InvalidWriter(uint256 index);
    error WriterOverride(uint256 index);
}

interface IBitAuthViews {
    function TOTAL_WRITERS() external view returns (uint256);

    function writerIndex(address writer) external view returns (uint8);
}

interface IBitAuth is IBitAuthErrors, IBitAuthViews, ISharedHashStorageAccessViews {}
