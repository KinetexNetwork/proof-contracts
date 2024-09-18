// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IProofVerifier} from "../../proof/interfaces/IProofVerifier.sol";
import {ProofHeader} from "../../proof/interfaces/ProofHeader.sol";

struct ProofMockData {
    bytes32 sig;
    bytes32 hash;
    uint256 chain;
}

contract ProofVerifierMock is IProofVerifier {
    error UnexpectedVariant(uint256 variant, uint256 expectedVariant);
    error UnexpectedSignature(bytes32 dataSignature, bytes32 paramSignature);
    error UnexpectedHash(bytes32 dataHash, bytes32 paramHash);
    error UnexpectedChain(uint256 dataChain, uint256 paramChain);

    uint256 public constant MOCK_PROOF_VARIANT = 133713371337;

    uint256 public verifiedProofCount;
    uint256 private _expectedVariant = MOCK_PROOF_VARIANT;

    function verifyHashEventProof(bytes32 sig_, bytes32 hash_, uint256 chain_, bytes calldata proof_) external {
        ProofHeader memory header = abi.decode(proof_, (ProofHeader));
        if (header.variant != _expectedVariant) revert UnexpectedVariant(header.variant, _expectedVariant);

        if (header.variant == MOCK_PROOF_VARIANT) {
            (, ProofMockData memory data) = abi.decode(proof_, (ProofHeader, ProofMockData));
            if (data.sig != sig_) revert UnexpectedSignature(data.sig, sig_);
            if (data.hash != hash_) revert UnexpectedHash(data.hash, hash_);
            if (data.chain != chain_) revert UnexpectedChain(data.chain, chain_);
        }

        verifiedProofCount++;
    }

    function setExpectedVariant(uint256 variant_) external {
        _expectedVariant = variant_;
    }
}
