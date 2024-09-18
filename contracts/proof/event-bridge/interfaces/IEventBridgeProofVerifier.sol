// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IProofVerifier} from "../../interfaces/IProofVerifier.sol";

import {IEventBridgeAdapter} from "../adapter/interfaces/IEventBridgeAdapter.sol";

interface IEventBridgeProofVerifierErrors {
    error InvalidAdapter();
    error EventNotReceived();
}

interface IEventBridgeProofVerifierViews {
    function ADAPTER() external view returns (IEventBridgeAdapter);
}

interface IEventBridgeProofVerifier is IProofVerifier, IEventBridgeProofVerifierErrors, IEventBridgeProofVerifierViews {}
