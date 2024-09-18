// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IProofVerifier} from "../../interfaces/IProofVerifier.sol";

import {IBitcoinLightClient} from "./IBitcoinLightClient.sol";
import {IBitcoinTransferConverter} from "./IBitcoinTransferConverter.sol";

import {SubmitOutputParams} from "./SubmitOutputParams.sol";
import {SubmitTransferParams} from "./SubmitTransferParams.sol";

interface IBitcoinProofVerifierErrors {
    error BlockNotConfirmed(bytes32 blockHash);
    error TransactionInclusionNotConfirmed(bytes32 txid, bytes32 blockHash);
    error TransactionTooEarly(uint32 time, uint32 minTime);
    error TransactionTooLate(uint32 time, uint32 maxTime);
    error InvalidInputAddress(bytes32 txid, uint64 vout, bytes24 addressHash, bytes24 requiredAddressHash);
    error InsufficientInputAmount(uint64 collectedAmount, uint64 requiredAmount);
    error InvalidOutputAddress(uint64 vout, bytes24 addressHash, bytes24 requiredAddressHash);
    error InsufficientOutputAmount(uint64 collectedAmount, uint64 requiredAmount);
    error TransferNotSubmitted(bytes32 transferHash);
    error TransferSubmittable(bytes32 transferHash, uint256 time, uint256 deadline);
    error TransferSubmitted(bytes32 transferHash);
}

interface IBitcoinProofVerifierViews {
    function LIGHT_CLIENT() external view returns (IBitcoinLightClient);

    function TRANSFER_CONVERTER() external view returns (IBitcoinTransferConverter);

    function outputAmount(bytes32 txid, uint64 vout) external view returns (uint64);

    function outputAddressHash(bytes32 txid, uint64 vout) external view returns (bytes24);

    function submittedTransfer(bytes32 transferHash) external view returns (bool);
}

interface IBitcoinProofVerifier is IProofVerifier, IBitcoinProofVerifierErrors, IBitcoinProofVerifierViews {
    function submitOutput(SubmitOutputParams calldata params) external;

    function submitTransfer(SubmitTransferParams calldata params) external;
}
