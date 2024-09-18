// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file, no-empty-blocks

pragma solidity 0.8.24;

import {IProofVerifier} from "../../interfaces/IProofVerifier.sol";

interface IProofVerifierRouterErrors {
    error NoVerifierRoute(uint256 chain, uint256 variant);
}

interface IProofVerifierRouterViews {
    function proofVerifier(uint256 chain, uint256 variant) external view returns (address);
}

interface IProofVerifierRouter is IProofVerifier, IProofVerifierRouterErrors, IProofVerifierRouterViews {}
