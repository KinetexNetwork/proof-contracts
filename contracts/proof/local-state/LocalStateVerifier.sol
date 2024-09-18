// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {ILocalStateVerifier, IHashStorageViews} from "./interfaces/ILocalStateVerifier.sol";

contract LocalStateVerifier is ILocalStateVerifier {
    IHashStorageViews public immutable EVENT_HASH_STORAGE;

    constructor(address eventHashStorage_) {
        if (eventHashStorage_ == address(0)) revert InvalidEventHashStorage();
        EVENT_HASH_STORAGE = IHashStorageViews(eventHashStorage_);
    }

    function _verifyEventHash(bytes32 hash_) internal view {
        if (!EVENT_HASH_STORAGE.hasHashStore(hash_)) revert EventHashNotStored();
    }
}
