// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {IHashStorage} from "../../storage/interfaces/IHashStorage.sol";

import {EventHashLib} from "../../utils/EventHashLib.sol";

import {IControlConfirmProofVerifier} from "./interfaces/IControlConfirmProofVerifier.sol";

contract ControlConfirmProofVerifier is IControlConfirmProofVerifier, Ownable2Step {
    IHashStorage private immutable _EVENT_HASH_STORAGE;

    constructor(address eventHashStorage_, address initialOwner_) Ownable(initialOwner_) {
        _EVENT_HASH_STORAGE = IHashStorage(eventHashStorage_);
    }

    function verifyHashEventProof(bytes32 sig_, bytes32 hash_, uint256, bytes calldata) external view {
        if (!_EVENT_HASH_STORAGE.hasHashStore(EventHashLib.calcEventHash(sig_, hash_))) revert EventNotReceived();
    }

    function confirm(bytes32 eventHash_) external onlyOwner {
        _EVENT_HASH_STORAGE.storeHash(eventHash_);
    }
}
