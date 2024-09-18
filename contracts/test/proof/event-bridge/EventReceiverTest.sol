// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventReceiver} from "../../../proof/event-bridge/transport/base/BaseEventReceiver.sol";

contract EventReceiverTest is BaseEventReceiver {
    string public constant PROVIDER = "test";

    // prettier-ignore
    constructor(address hashStorage_)
        BaseEventReceiver(
            hashStorage_,
            ~uint256(0), // Sender chain is not used
            address(~uint160(0)) // Sender address is not used
        )
    {}

    function receivePayload(bytes calldata payload_) external {
        _receivePayload(payload_);
    }
}
