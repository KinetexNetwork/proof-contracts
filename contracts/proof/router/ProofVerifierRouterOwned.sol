// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

import {IProofVerifierRouterOwned} from "./interfaces/IProofVerifierRouterOwned.sol";

import {ProofVerifierRouter} from "./ProofVerifierRouter.sol";

contract ProofVerifierRouterOwned is IProofVerifierRouterOwned, ProofVerifierRouter, Ownable2Step, Multicall {
    constructor(address initialOwner_) Ownable(initialOwner_) {}

    function setRouteVerifier(uint256 chain_, uint256 variant_, address verifier_) external onlyOwner {
        address oldVerifier = proofVerifier[chain_][variant_];
        if (oldVerifier == verifier_) revert SameRouteVerifier(chain_, variant_, verifier_);
        proofVerifier[chain_][variant_] = verifier_;
        emit RouteVerifierUpdate(chain_, variant_, oldVerifier, verifier_);
    }
}
