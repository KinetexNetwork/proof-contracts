// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

import {EnvLib} from "../../utils/EnvLib.sol";

import {IBitcoinProofVerifier, IBitcoinLightClient, IBitcoinTransferConverter, SubmitOutputParams, SubmitTransferParams} from "./interfaces/IBitcoinProofVerifier.sol";
import {BitcoinProofData} from "./interfaces/BitcoinProofData.sol";

import {BitcoinLib} from "./BitcoinLib.sol";
import {BitcoinTransferLib} from "./BitcoinTransferLib.sol";

contract BitcoinProofVerifier is IBitcoinProofVerifier, Multicall {
    IBitcoinLightClient public immutable LIGHT_CLIENT;
    IBitcoinTransferConverter public immutable TRANSFER_CONVERTER;

    mapping(bytes32 txid => mapping(uint64 vout => uint256)) private _outputData;
    mapping(bytes32 transferHash => bool) public submittedTransfer;

    constructor(address lightClient_, address transferConverter_) {
        LIGHT_CLIENT = IBitcoinLightClient(lightClient_);
        TRANSFER_CONVERTER = IBitcoinTransferConverter(transferConverter_);
    }

    function verifyHashEventProof(bytes32 sig_, bytes32 hash_, uint256, bytes calldata proof_) external {
        BitcoinProofData calldata data;
        assembly { data := add(proof_.offset, 64) } // prettier-ignore

        for (uint256 i = 0; i < data.outputSubmits.length; i++) this.submitOutput(data.outputSubmits[i]);
        for (uint256 i = 0; i < data.transferSubmits.length; i++) this.submitTransfer(data.transferSubmits[i]);

        (bytes32 transferHash, uint256 deadline) = TRANSFER_CONVERTER.convertToTransfer(sig_, hash_, proof_);
        if (deadline == 0) _verifyHasTransfer(transferHash);
        else _verifyNoTransfer(transferHash, deadline);
    }

    function submitOutput(SubmitOutputParams calldata params_) external {
        _createTransactionOutputs(params_.transaction, params_.outputs);
    }

    function submitTransfer(SubmitTransferParams calldata params_) public {
        _verifyTransactionInclusion(params_.transaction, params_.blockHeader, params_.merkleBranch, params_.merkleOrders);
        _verifyTransferTime(params_.blockHeader, params_.timeData);
        _verifyTransferIo(params_.transaction, params_.inputs, params_.inputAddressHash, params_.outputs, params_.outputAddressHash, params_.minAmount);
        _createTransfer(params_.inputAddressHash, params_.outputAddressHash, params_.minAmount, params_.timeData);
    }

    function outputAmount(bytes32 txid_, uint64 vout_) external view returns (uint64) {
        return _outputDataAmount(_outputData[txid_][vout_]);
    }

    function outputAddressHash(bytes32 txid_, uint64 vout_) external view returns (bytes24) {
        return _outputDataAddressHash(_outputData[txid_][vout_]);
    }

    function _verifyTransactionInclusion(
        bytes calldata transaction_,
        bytes calldata blockHeader_,
        bytes32[] calldata merkleBranch_,
        uint256 merkleOrders_
    ) internal view returns (bytes32 txid) {
        bytes32 blockHash = BitcoinLib.calcBlockHash(blockHeader_);
        if (!LIGHT_CLIENT.blockConfirmed(blockHash)) revert BlockNotConfirmed(blockHash);

        txid = BitcoinLib.calcTransactionHash(transaction_);
        bytes32 merkleRoot = BitcoinLib.readBlockMerkleRoot(blockHeader_);
        if (!BitcoinLib.checkTxidInMerkleRoot(txid, merkleRoot, merkleBranch_, merkleOrders_)) revert TransactionInclusionNotConfirmed(txid, blockHash);
    }

    function _verifyTransferTime(bytes calldata blockHeader_, uint64 timeData_) private pure {
        uint32 blockTime = BitcoinLib.readBlockTime(blockHeader_);
        uint32 transferStart = uint32(timeData_);
        if (blockTime < transferStart) revert TransactionTooEarly(blockTime, transferStart);
        uint32 transferEnd = transferStart + uint32(timeData_ >> 32);
        if (blockTime > transferEnd) revert TransactionTooLate(blockTime, transferEnd);
    }

    function _createTransactionOutputs(bytes calldata transaction_, uint256[] calldata outputs_) private {
        bytes32 txid = BitcoinLib.calcTransactionHash(transaction_);
        (uint64 count, uint256 cursor) = BitcoinLib.readOutputs(transaction_);
        uint256 output;
        for (uint64 vout = 0; vout < count; vout++) {
            if (vout % 256 == 0) output = outputs_[vout / 256];
            if (output & 1 == 0) cursor = BitcoinLib.skipOutput(transaction_, cursor);
            else {
                uint64 amount;
                string memory address_;
                (amount, address_, cursor) = BitcoinLib.readOutput(transaction_, cursor);
                _outputData[txid][vout] = _createOutputData(amount, BitcoinTransferLib.calcAddressHash(address_));
            }
            output >>= 1;
        }
    }

    function _verifyTransferIo(
        bytes calldata transaction_,
        uint256[] calldata inputs_,
        bytes24 inputAddressHash_,
        uint256[] calldata outputs_,
        bytes24 outputAddressHash_,
        uint64 minAmount_
    ) internal view {
        uint256 cursor = _verifyTransferInputs(transaction_, inputs_, inputAddressHash_, minAmount_);
        _verifyTransferOutputs(transaction_, outputs_, outputAddressHash_, minAmount_, cursor);
    }

    function _verifyTransferInputs(
        bytes calldata transaction_,
        uint256[] calldata inputs_,
        bytes24 addressHash_,
        uint64 minAmount_
    ) private view returns (uint256 cursor) {
        uint64 count;
        (count, cursor) = BitcoinLib.readInputs(transaction_);

        uint256 input;
        uint64 collectedAmount = 0;
        for (uint64 vin = 0; vin < count; vin++) {
            if (vin % 256 == 0) input = inputs_[vin / 256];
            if (input & 1 == 0) cursor = BitcoinLib.skipInput(transaction_, cursor);
            else {
                bytes32 txid;
                uint64 vout;
                (txid, vout, cursor) = BitcoinLib.readInput(transaction_, cursor);
                uint256 data = _outputData[txid][vout];
                if (addressHash_ != BitcoinTransferLib.ANY_BITCOIN_ADDRESS_HASH && _outputDataAddressHash(data) != addressHash_)
                    revert InvalidInputAddress(txid, vout, _outputDataAddressHash(data), addressHash_);
                collectedAmount += _outputDataAmount(data);
            }
            input >>= 1;
        }

        if (collectedAmount < minAmount_) revert InsufficientInputAmount(collectedAmount, minAmount_);
    }

    function _verifyTransferOutputs(
        bytes calldata transaction_,
        uint256[] calldata outputs_,
        bytes24 addressHash_,
        uint64 minAmount_,
        uint256 cursor_
    ) private pure {
        uint64 count;
        (count, cursor_) = BitcoinLib.readOutputs(transaction_, cursor_);

        uint256 output;
        uint64 collectedAmount = 0;
        for (uint64 vout = 0; vout < count; vout++) {
            if (vout % 256 == 0) output = outputs_[vout / 256];
            if (output & 1 == 0) cursor_ = BitcoinLib.skipOutput(transaction_, cursor_);
            else {
                uint64 amount;
                string memory address_;
                (amount, address_, cursor_) = BitcoinLib.readOutput(transaction_, cursor_);
                if (BitcoinTransferLib.calcAddressHash(address_) != addressHash_)
                    revert InvalidOutputAddress(vout, BitcoinTransferLib.calcAddressHash(address_), addressHash_);
                collectedAmount += amount;
                if (collectedAmount >= minAmount_) return;
            }
            output >>= 1;
        }

        revert InsufficientOutputAmount(collectedAmount, minAmount_);
    }

    function _createTransfer(bytes24 inputAddressHash_, bytes24 outputAddressHash_, uint64 minAmount_, uint64 timeData_) private {
        bytes32 transferHash = BitcoinTransferLib.calcTransferHash(inputAddressHash_, outputAddressHash_, minAmount_, timeData_);
        submittedTransfer[transferHash] = true;
    }

    function _verifyHasTransfer(bytes32 transferHash_) private view {
        if (!submittedTransfer[transferHash_]) revert TransferNotSubmitted(transferHash_);
    }

    function _verifyNoTransfer(bytes32 transferHash_, uint256 deadline_) private view {
        if (EnvLib.isActiveDeadline(deadline_)) revert TransferSubmittable(transferHash_, EnvLib.timeNow(), deadline_);
        if (submittedTransfer[transferHash_]) revert TransferSubmitted(transferHash_);
    }

    function _createOutputData(uint64 amount_, bytes24 addressHash_) internal pure returns (uint256) {
        return uint256(amount_) | uint256(bytes32(addressHash_));
    }

    function _outputDataAmount(uint256 data_) internal pure returns (uint64) {
        return uint64(data_);
    }

    function _outputDataAddressHash(uint256 data_) internal pure returns (bytes24) {
        return bytes24(bytes32(data_));
    }
}
