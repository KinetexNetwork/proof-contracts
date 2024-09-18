// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IProofVerifierRouter, IProofVerifier} from "./interfaces/IProofVerifierRouter.sol";

abstract contract ProofVerifierRouter is IProofVerifierRouter {
    mapping(uint256 chain => mapping(uint256 variant => address)) public proofVerifier;

    function verifyHashEventProof(bytes32 sig_, bytes32 hash_, uint256 chain_, bytes calldata proof_) external {
        uint256 variant;
        assembly { variant := calldataload(proof_.offset) } // prettier-ignore
        address verifier = proofVerifier[chain_][variant];
        if (verifier == address(0)) revert NoVerifierRoute(chain_, variant);
        IProofVerifier(verifier).verifyHashEventProof(sig_, hash_, chain_, proof_);
    }
}
