// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct SubmitTransferParams {
    bytes transaction;
    uint256[] inputs;
    bytes24 inputAddressHash;
    uint256[] outputs;
    bytes24 outputAddressHash;
    uint64 minAmount;
    uint64 timeData; // Duration (32), Start (32)
    bytes blockHeader;
    bytes32[] merkleBranch;
    uint256 merkleOrders;
}
