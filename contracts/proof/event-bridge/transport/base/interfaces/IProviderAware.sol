// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

interface IProviderAwareViews {
    function PROVIDER() external view returns (string memory);
}

interface IProviderAware is IProviderAwareViews {}
