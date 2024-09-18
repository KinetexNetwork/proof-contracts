// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {EventLib} from "./EventLib.sol";

library HashEventLib {
    error InvalidEventHash(bytes32 eventHash, bytes32 requiredEventHash);

    // Topic #0 is hash of event signature. The hash param is in the next topic
    uint256 private constant HASH_TOPIC_INDEX = 1;

    function verifyHashEvent(
        bytes[] memory receiptProof_,
        bytes32 receiptRoot_,
        bytes memory txIndexRLPEncoded_,
        uint256 logIndex_,
        address claimedEmitter_,
        bytes32 eventSignature_,
        bytes32 claimedHash_
    ) internal pure {
        bytes32 eventHash = EventLib.getEventTopic(
            receiptProof_,
            receiptRoot_,
            txIndexRLPEncoded_,
            logIndex_,
            claimedEmitter_,
            eventSignature_,
            HASH_TOPIC_INDEX
        );
        if (eventHash != claimedHash_) revert InvalidEventHash(eventHash, claimedHash_);
    }
}
