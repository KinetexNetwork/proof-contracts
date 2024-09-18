// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {RLPReader} from "@eth-optimism/contracts-bedrock/src/libraries/rlp/RLPReader.sol";
import {MerkleTrie} from "@eth-optimism/contracts-bedrock/src/libraries/trie/MerkleTrie.sol";

import {RLPReaderExt} from "./RLPReaderExt.sol";

library EventLib {
    using RLPReader for RLPReader.RLPItem;
    using RLPReaderExt for RLPReader.RLPItem;

    error InvalidTransactionType(uint8 firstByte);
    error InvalidReceiptLength(uint256 length, uint256 requiredLength);
    error InvalidLogIndex(uint256 index, uint256 length);
    error InvalidLogLength(uint256 length, uint256 requiredLength);
    error LogEmitterMismatch(address emitter, address claimedEmitter);
    error EventSignatureMismatch(bytes32 signature, bytes32 requiredSignature);

    function getEventTopic(
        bytes[] memory proof_,
        bytes32 receiptRoot_,
        bytes memory key_,
        uint256 logIndex_,
        address claimedEmitter_,
        bytes32 eventSignature_,
        uint256 topicIndex_
    ) internal pure returns (bytes32) {
        bytes memory value = MerkleTrie.get(key_, proof_, receiptRoot_);
        uint8 firstByte = uint8(value[0]);

        // Currently, there are three possible transaction types on Ethereum. Receipts either come
        // in the form "TransactionType | ReceiptPayload" or "ReceiptPayload". The currently
        // supported set of transaction types are 0x01 and 0x02. In this case, we must truncate
        // the first byte to access the payload. To detect the other case, we can use the fact
        // that the first byte of a RLP-encoded list will always be greater than 0xc0.
        // Reference 1: https://eips.ethereum.org/EIPS/eip-2718
        // Reference 2: https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp
        uint256 offset;
        if (firstByte == 0x01 || firstByte == 0x02) offset = 1;
        else if (firstByte >= 0xc0) offset = 0;
        else revert InvalidTransactionType(firstByte);

        // Truncate the first byte if presented and get the RLP decoding of the receipt.
        uint256 ptr;
        assembly { ptr := add(value, 32) } // prettier-ignore
        RLPReader.RLPItem memory valueAsItem = RLPReader.RLPItem({length: value.length - offset, ptr: RLPReader.MemoryPointer.wrap(ptr + offset)});

        // The length of the receipt must be at least four, as the fourth entry contains events
        RLPReader.RLPItem[] memory valueAsList = valueAsItem.readList();
        if (valueAsList.length != 4) revert InvalidReceiptLength(valueAsList.length, 4);

        // Read the logs from the receipts and check that it is not ill-formed
        RLPReader.RLPItem[] memory logs = valueAsList[3].readList();
        if (logIndex_ >= logs.length) revert InvalidLogIndex(logIndex_, logs.length);
        RLPReader.RLPItem[] memory relevantLog = logs[logIndex_].readList();
        if (relevantLog.length != 3) revert InvalidLogLength(relevantLog.length, 3);

        // Validate that the correct contract emitted the event
        address emitter = relevantLog[0].readAddress();
        if (emitter != claimedEmitter_) revert LogEmitterMismatch(emitter, claimedEmitter_);
        RLPReader.RLPItem[] memory topics = relevantLog[1].readList();

        // Validate that the correct event was emitted by checking the event signature
        bytes32 signatureTopic = topics[0].readBytes32();
        if (signatureTopic != eventSignature_) revert EventSignatureMismatch(signatureTopic, eventSignature_);

        return topics[topicIndex_].readBytes32();
    }
}
