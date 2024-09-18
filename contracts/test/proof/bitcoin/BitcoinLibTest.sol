// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BitcoinLib} from "../../../proof/bitcoin/BitcoinLib.sol";

struct TransactionInput {
    bytes32 txid;
    uint32 vout;
}

struct TransactionOutput {
    string address_;
    uint64 amount;
}

struct Transaction {
    TransactionInput[] inputs;
    TransactionOutput[] outputs;
}

contract BitcoinLibTest {
    function calcBlockHash(bytes calldata blockHeader_) external pure returns (bytes32) {
        return BitcoinLib.calcBlockHash(blockHeader_);
    }

    function readBlockMerkleRoot(bytes calldata blockHeader_) external pure returns (bytes32) {
        return BitcoinLib.readBlockMerkleRoot(blockHeader_);
    }

    function readBlockTime(bytes calldata blockHeader_) external pure returns (uint32) {
        return BitcoinLib.readBlockTime(blockHeader_);
    }

    function calcTransactionHash(bytes calldata transaction_) external pure returns (bytes32) {
        return BitcoinLib.calcTransactionHash(transaction_);
    }

    function checkTxidInMerkleRoot(bytes32 txid_, bytes32 root_, bytes32[] calldata branch_, uint256 orders_) external pure returns (bool) {
        return BitcoinLib.checkTxidInMerkleRoot(txid_, root_, branch_, orders_);
    }

    function readCompactInt(bytes calldata data_, uint256 offset_) external pure returns (uint64, uint8) {
        return BitcoinLib.readCompactInt(data_, offset_);
    }

    function readScriptAddress(bytes calldata data_, uint256 offset_) external pure returns (string memory) {
        return BitcoinLib.readScriptAddress(data_, offset_);
    }

    function readAddressAsP2PKH(bytes calldata data_, uint256 offset_) external pure returns (string memory) {
        return BitcoinLib.readAddressAsP2PKH(data_, offset_);
    }

    function readAddressAsP2SH(bytes calldata data_, uint256 offset_) external pure returns (string memory) {
        return BitcoinLib.readAddressAsP2SH(data_, offset_);
    }

    function readAddressAsP2WPKH(bytes calldata data_, uint256 offset_) external pure returns (string memory) {
        return BitcoinLib.readAddressAsP2WPKH(data_, offset_);
    }

    function readAddressAsP2WSH(bytes calldata data_, uint256 offset_) external pure returns (string memory) {
        return BitcoinLib.readAddressAsP2WSH(data_, offset_);
    }

    function readAddressAsP2TR(bytes calldata data_, uint256 offset_) external pure returns (string memory) {
        return BitcoinLib.readAddressAsP2TR(data_, offset_);
    }

    function readOutputAmount(bytes calldata data_, uint256 offset_) external pure returns (uint64) {
        return BitcoinLib.readOutputAmount(data_, offset_);
    }

    function parseTransaction(bytes calldata transaction_) external pure returns (Transaction memory transaction) {
        (uint64 count, uint256 cursor) = BitcoinLib.readInputs(transaction_);
        transaction.inputs = new TransactionInput[](count);
        for (uint64 i = 0; i < count; i++) {
            (transaction.inputs[i].txid, transaction.inputs[i].vout, cursor) = BitcoinLib.readInput(transaction_, cursor);
        }

        (count, cursor) = BitcoinLib.readOutputs(transaction_, cursor);
        transaction.outputs = new TransactionOutput[](count);
        for (uint64 i = 0; i < count; i++) {
            (transaction.outputs[i].amount, transaction.outputs[i].address_, cursor) = BitcoinLib.readOutput(transaction_, cursor);
        }
    }
}
