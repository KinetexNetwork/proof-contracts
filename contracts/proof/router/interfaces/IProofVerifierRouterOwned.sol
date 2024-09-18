// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-empty-blocks

pragma solidity 0.8.24;

import {IProofVerifierRouter} from "./IProofVerifierRouter.sol";

interface IProofVerifierRouterOwnedErrors {
    error SameRouteVerifier(uint256 chain, uint256 variant, address verifier);
}

interface IProofVerifierRouterOwnedEvents {
    event RouteVerifierUpdate(uint256 chain, uint256 variant, address oldVerifier, address newVerifier);
}

interface IProofVerifierRouterOwned is IProofVerifierRouter, IProofVerifierRouterOwnedErrors, IProofVerifierRouterOwnedEvents {
    function setRouteVerifier(uint256 chain, uint256 variant, address verifier) external;
}
