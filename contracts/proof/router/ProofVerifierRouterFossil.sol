// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IProofVerifierRouterFossil, VerifierFossilConfig} from "./interfaces/IProofVerifierRouterFossil.sol";

import {ProofVerifierRouter} from "./ProofVerifierRouter.sol";

contract ProofVerifierRouterFossil is IProofVerifierRouterFossil, ProofVerifierRouter {
    constructor(VerifierFossilConfig[] memory verifierConfigs_) {
        for (uint256 i = 0; i < verifierConfigs_.length; i++) {
            VerifierFossilConfig memory vc = verifierConfigs_[i];
            if (vc.chain == 0) revert InvalidConfigChain(i);
            if (vc.verifier == address(0)) revert InvalidConfigVerifier(i);
            if (proofVerifier[vc.chain][vc.variant] != address(0)) revert VerifierConfigOverride(i);
            proofVerifier[vc.chain][vc.variant] = vc.verifier;
        }
    }
}
