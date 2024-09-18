// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file

pragma solidity 0.8.24;

import {IProofVerifier} from "../../interfaces/IProofVerifier.sol";

interface IControlConfirmProofVerifierErrors {
    error EventNotReceived();
}

interface IControlConfirmProofVerifier is IProofVerifier, IControlConfirmProofVerifierErrors {
    function confirm(bytes32 eventHash) external;
}
