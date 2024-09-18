// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {EventBridgeHashLib} from "../../EventBridgeHashLib.sol";

import {IBaseEventReceiver, ISharedHashStorage} from "./interfaces/IBaseEventReceiver.sol";

abstract contract BaseEventReceiver is IBaseEventReceiver {
    ISharedHashStorage public immutable EVENT_HASH_STORAGE;
    uint256 public immutable SENDER_CHAIN;
    address public immutable SENDER_ADDRESS;

    constructor(address eventHashStorage_, uint256 senderChain_, address senderAddress_) {
        if (eventHashStorage_ == address(0)) revert InvalidEventHashStorage();
        if (senderChain_ == 0) revert InvalidSenderChain();
        if (senderAddress_ == address(0)) revert InvalidSenderAddress();
        EVENT_HASH_STORAGE = ISharedHashStorage(eventHashStorage_);
        SENDER_CHAIN = senderChain_;
        SENDER_ADDRESS = senderAddress_;
    }

    function eventHashesReceived(bytes32 eventsHash_) public view returns (bool) {
        return EVENT_HASH_STORAGE.isHashStoredBy(eventsHash_, address(this));
    }

    function restoreEventHashes(bytes32[] calldata eventHashes_) external {
        if (!eventHashesReceived(EventBridgeHashLib.calcEventsHash(eventHashes_))) revert RestoreHashNotReceived();
        for (uint256 i = 0; i < eventHashes_.length; i++) EVENT_HASH_STORAGE.storeHash(eventHashes_[i]);
    }

    function _receivePayload(bytes memory payload_) internal {
        if (payload_.length != 32) revert InvalidEventPayload();
        EVENT_HASH_STORAGE.storeHash(abi.decode(payload_, (bytes32)));
    }
}
