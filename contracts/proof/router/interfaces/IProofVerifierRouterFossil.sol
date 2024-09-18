// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks

pragma solidity 0.8.24;

import {IProofVerifierRouter} from "./IProofVerifierRouter.sol";
import {VerifierFossilConfig} from "./VerifierFossilConfig.sol";

interface IProofVerifierRouterFossilErrors {
    error InvalidConfigChain(uint256 index);
    error InvalidConfigVerifier(uint256 index);
    error VerifierConfigOverride(uint256 index);
}

interface IProofVerifierRouterFossil is IProofVerifierRouter, IProofVerifierRouterFossilErrors {}
