// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IProofVerifier} from "../../interfaces/IProofVerifier.sol";

interface ISignatureProofVerifierErrors {
    error InvalidEventSignature();
}

interface ISignatureProofVerifier is IProofVerifier, ISignatureProofVerifierErrors {}
