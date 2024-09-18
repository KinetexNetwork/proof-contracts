// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IProofVerifier} from "../../proof/interfaces/IProofVerifier.sol";
import {ProofVerifierRouterFossil, VerifierFossilConfig} from "../../proof/router/ProofVerifierRouterFossil.sol";

contract ProofVerifierTest {
    IProofVerifier public immutable ROUTER;

    uint256 public lastGasUsed;

    constructor(uint256 chain_, uint256 variant_, address verifier_) {
        VerifierFossilConfig[] memory configs = new VerifierFossilConfig[](1);
        configs[0] = VerifierFossilConfig({chain: chain_, variant: variant_, verifier: verifier_});
        ROUTER = new ProofVerifierRouterFossil(configs);
    }

    function verifyHashEventProofTest(bytes32 sig_, bytes32 hash_, uint256 chain_, bytes calldata proof_) external {
        uint256 gasBefore = gasleft();
        ROUTER.verifyHashEventProof(sig_, hash_, chain_, proof_);
        uint256 gasAfter = gasleft();
        lastGasUsed = gasBefore - gasAfter;
    }
}
