// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {EventHashLib} from "../../utils/EventHashLib.sol";

import {IEventBridgeProofVerifier, IEventBridgeAdapter} from "./interfaces/IEventBridgeProofVerifier.sol";

contract EventBridgeProofVerifier is IEventBridgeProofVerifier {
    IEventBridgeAdapter public immutable ADAPTER;

    constructor(address adapter_) {
        if (adapter_ == address(0)) revert InvalidAdapter();
        ADAPTER = IEventBridgeAdapter(adapter_);
    }

    function verifyHashEventProof(bytes32 sig_, bytes32 hash_, uint256, bytes calldata) external view {
        if (!ADAPTER.eventReceived(EventHashLib.calcEventHash(sig_, hash_))) revert EventNotReceived();
    }
}
