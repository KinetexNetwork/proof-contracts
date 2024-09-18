// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

interface IBitcoinTransferConverter {
    function convertToTransfer(bytes32 sig, bytes32 hash, bytes calldata proof) external view returns (bytes32 transferHash, uint256 deadline);
}
