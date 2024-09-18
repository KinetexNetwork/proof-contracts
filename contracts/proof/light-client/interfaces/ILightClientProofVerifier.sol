// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IProofVerifier} from "../../interfaces/IProofVerifier.sol";

import {ILightClient} from "./ILightClient.sol";

interface ILightClientProofVerifierErrors {
    error InvalidChain(uint256 chain, uint256 requiredChain);
    error LightClientInconsistent();
    error NoSlotTimestamp(uint256 slot);
    error SlotNotSettled(uint256 slot, uint256 elapsedTime, uint256 minDelay);
    error NoHeaderRoot(uint256 slot);
}

interface ILightClientProofVerifierViews {
    function CHAIN() external returns (uint256);

    function LIGHT_CLIENT() external returns (ILightClient);

    function BROADCASTER() external returns (address);

    function MIN_DELAY() external returns (uint256);
}

interface ILightClientProofVerifier is IProofVerifier, ILightClientProofVerifierErrors, ILightClientProofVerifierViews {}
