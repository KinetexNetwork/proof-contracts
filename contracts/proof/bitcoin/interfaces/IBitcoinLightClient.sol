// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

interface IBitcoinLightClient {
    function blockConfirmed(bytes32 blockHash) external view returns (bool);
}
