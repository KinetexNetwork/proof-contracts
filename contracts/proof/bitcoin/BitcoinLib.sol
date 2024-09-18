// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {Base58} from "./Base58.sol";
import {Bech32} from "./Bech32.sol";

library BitcoinLib {
    error InvalidScriptType();

    function calcBlockHash(bytes calldata blockHeader_) internal pure returns (bytes32) {
        return sha256(abi.encode(sha256(blockHeader_)));
    }

    function readBlockMerkleRoot(bytes calldata blockHeader_) internal pure returns (bytes32) {
        return bytes32(blockHeader_[36:68]); // Version (4), Previous Block (32), Merkle Root (32)
    }

    function readBlockTime(bytes calldata blockHeader_) internal pure returns (uint32) {
        return uint32(_readLittleEndianInt(blockHeader_, 68, 4)); // Version (4), Previous Block (32), Merkle Root (32), Time (4)
    }

    function calcTransactionHash(bytes calldata transaction_) internal pure returns (bytes32) {
        return _isSegWit(transaction_) ? _calcSegWitHash(transaction_) : _calcLegacyHash(transaction_);
    }

    function checkTxidInMerkleRoot(bytes32 txid_, bytes32 root_, bytes32[] calldata branch_, uint256 orders_) internal pure returns (bool) {
        if (branch_.length == 0) return false;
        for (uint256 i = 0; i < branch_.length; i++) {
            bytes memory concat = (orders_ & 1) == 0 ? abi.encode(branch_[i], txid_) : abi.encode(txid_, branch_[i]);
            txid_ = sha256(abi.encode(sha256(concat)));
            orders_ >>= 1;
        }
        return txid_ == root_;
    }

    function readCompactInt(bytes calldata data_, uint256 offset_) internal pure returns (uint64 value, uint8 length) {
        uint8 flag = uint8(data_[offset_]);
        if (flag <= 0xFC) return (flag, 1);
        if (flag == 0xFD) return (_readLittleEndianInt(data_, offset_ + 1, 2), 3);
        if (flag == 0xFE) return (_readLittleEndianInt(data_, offset_ + 1, 4), 5);
        return (_readLittleEndianInt(data_, offset_ + 1, 8), 9);
    }

    // prettier-ignore
    function readScriptAddress(bytes calldata data_, uint256 offset_) internal pure returns (string memory) {
        if (data_[offset_] == 0x51 && data_[offset_ + 1] == 0x20) return readAddressAsP2TR(data_, offset_);
        if (data_[offset_] == 0x00 && data_[offset_ + 1] == 0x14) return readAddressAsP2WPKH(data_, offset_);
        if (data_[offset_] == 0x00 && data_[offset_ + 1] == 0x20) return readAddressAsP2WSH(data_, offset_);
        if (data_[offset_] == 0x76 && data_[offset_ + 1] == 0xA9 && data_[offset_ + 2] == 0x14 && data_[offset_ + 23] == 0x88 && data_[offset_ + 24] == 0xAC) return readAddressAsP2PKH(data_, offset_);
        if (data_[offset_] == 0xA9 && data_[offset_ + 1] == 0x14 && data_[offset_ + 22] == 0x87) return readAddressAsP2SH(data_, offset_);
        revert InvalidScriptType(); // Non-standard script, including data storage (OP_RETURN), no-address relic (P2PK, P2MS), etc
    }

    function readAddressAsP2PKH(bytes calldata data_, uint256 offset_) internal pure returns (string memory) {
        return _readBase58Address(data_, offset_ + 3, 0x00);
    }

    function readAddressAsP2SH(bytes calldata data_, uint256 offset_) internal pure returns (string memory) {
        return _readBase58Address(data_, offset_ + 2, 0x05);
    }

    function readAddressAsP2WPKH(bytes calldata data_, uint256 offset_) internal pure returns (string memory) {
        return _readBech32Address(data_, offset_ + 2, 20, 0);
    }

    function readAddressAsP2WSH(bytes calldata data_, uint256 offset_) internal pure returns (string memory) {
        return _readBech32Address(data_, offset_ + 2, 32, 0);
    }

    function readAddressAsP2TR(bytes calldata data_, uint256 offset_) internal pure returns (string memory) {
        return _readBech32Address(data_, offset_ + 2, 32, 1);
    }

    function readOutputAmount(bytes calldata data_, uint256 offset_) internal pure returns (uint64) {
        return _readLittleEndianInt(data_, offset_, 8); // Amount (8)
    }

    function readInputs(bytes calldata transaction_) internal pure returns (uint64 count, uint256 cursor) {
        return _readPartsCount(transaction_, _skipFlags(transaction_));
    }

    function readInput(bytes calldata transaction_, uint256 cursor_) internal pure returns (bytes32 txid, uint32 vout, uint256 nextCursor) {
        txid = bytes32(transaction_[cursor_:cursor_ + 32]); // TXID (32)
        cursor_ += 32; // TXID (32)
        vout = uint32(_readLittleEndianInt(transaction_, cursor_, 4)); // VOUT (4)
        cursor_ += 4; // VOUT (4)
        (uint64 size, uint8 length) = readCompactInt(transaction_, cursor_); // Script size
        cursor_ += size + length + 4; // Sequence (4)
        nextCursor = cursor_;
    }

    function skipInput(bytes calldata transaction_, uint256 cursor_) internal pure returns (uint256 nextCursor) {
        cursor_ += 36; // TXID (32) + VOUT (4)
        (uint64 size, uint8 length) = readCompactInt(transaction_, cursor_); // Script size
        cursor_ += size + length + 4; // Sequence (4)
        return cursor_;
    }

    function readOutputs(bytes calldata transaction_, uint256 cursor_) internal pure returns (uint64 count, uint256 nextCursor) {
        return _readPartsCount(transaction_, cursor_);
    }

    function readOutputs(bytes calldata transaction_) internal pure returns (uint64 count, uint256 cursor) {
        return readOutputs(transaction_, _skipInputs(transaction_, _skipFlags(transaction_)));
    }

    function readOutput(bytes calldata transaction_, uint256 cursor_) internal pure returns (uint64 amount, string memory address_, uint256 nextCursor) {
        amount = readOutputAmount(transaction_, cursor_);
        cursor_ += 8; // Amount (8)
        (uint64 size, uint8 length) = readCompactInt(transaction_, cursor_); // Script size
        cursor_ += length;
        address_ = readScriptAddress(transaction_, cursor_);
        cursor_ += size;
        nextCursor = cursor_;
    }

    function skipOutput(bytes calldata transaction_, uint256 cursor_) internal pure returns (uint256 nextCursor) {
        cursor_ += 8; // Amount (8)
        (uint64 size, uint8 length) = readCompactInt(transaction_, cursor_); // Script size
        cursor_ += size + length;
        return cursor_;
    }

    function _readLittleEndianInt(bytes calldata data_, uint256 offset_, uint256 bytes_) private pure returns (uint64 value) {
        for (uint64 i = 0; i < bytes_; i++) value |= uint64(uint8(data_[offset_ + i])) << (i * 8);
    }

    function _readBase58Address(bytes calldata data_, uint256 offset_, bytes1 prefix_) private pure returns (string memory) {
        bytes memory addressData = bytes.concat(prefix_, data_[offset_:offset_ + 20]);
        bytes4 checksum = bytes4(sha256(abi.encode(sha256(addressData))));
        addressData = bytes.concat(addressData, checksum);
        return Base58.encode(addressData);
    }

    function _readBech32Address(bytes calldata data_, uint256 offset_, uint256 length_, uint8 version_) private pure returns (string memory) {
        return Bech32.encode("bc", version_, data_[offset_:offset_ + length_]);
    }

    function _isSegWit(bytes calldata transaction_) private pure returns (bool) {
        return transaction_[4] == 0x00 && transaction_[5] > 0x00;
    }

    function _calcSegWitHash(bytes calldata transaction_) private pure returns (bytes32) {
        uint256 cursor = _skipInputs(transaction_, _skipFlags(transaction_));
        cursor = _skipOutputs(transaction_, cursor);

        // Marker (1), Flag (1), and Witness (dynamic) fields are excluded from SegWit transaction hash.
        // Fields included in the hash: Version (4), Inputs (dynamic), Outputs (dynamic), Locktime (4)
        bytes memory concat = bytes.concat(transaction_[0:4], transaction_[6:cursor], transaction_[transaction_.length - 4:transaction_.length]);
        return sha256(abi.encode(sha256(concat)));
    }

    function _calcLegacyHash(bytes calldata transaction_) private pure returns (bytes32) {
        return sha256(abi.encode(sha256(transaction_)));
    }

    function _skipFlags(bytes calldata transaction_) private pure returns (uint256 cursor) {
        return _isSegWit(transaction_) ? 6 : 4; // Version (4) + [SegWit]: Marker (1) + Flag (1)
    }

    function _skipInputs(bytes calldata transaction_, uint256 cursor_) private pure returns (uint256 nextCursor) {
        uint64 count;
        (count, cursor_) = _readPartsCount(transaction_, cursor_);
        for (; count > 0; count--) cursor_ = skipInput(transaction_, cursor_);
        return cursor_;
    }

    function _skipOutputs(bytes calldata transaction_, uint256 cursor_) private pure returns (uint256 nextCursor) {
        uint64 count;
        (count, cursor_) = _readPartsCount(transaction_, cursor_);
        for (; count > 0; count--) cursor_ = skipOutput(transaction_, cursor_);
        return cursor_;
    }

    function _readPartsCount(bytes calldata transaction_, uint256 cursor_) private pure returns (uint64 count, uint256 nextCursor) {
        (count, nextCursor) = readCompactInt(transaction_, cursor_);
        nextCursor += cursor_;
    }
}
