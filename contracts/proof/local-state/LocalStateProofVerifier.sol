// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {EventHashLib} from "../../utils/EventHashLib.sol";

import {ILocalStateProofVerifier} from "./interfaces/ILocalStateProofVerifier.sol";

import {LocalStateVerifier} from "./LocalStateVerifier.sol";

contract LocalStateProofVerifier is ILocalStateProofVerifier, LocalStateVerifier {
    constructor(address eventHashStorage_) LocalStateVerifier(eventHashStorage_) {}

    function verifyHashEventProof(bytes32 sig_, bytes32 hash_, uint256, bytes calldata) external view {
        _verifyEventHash(EventHashLib.calcEventHash(sig_, hash_));
    }
}
