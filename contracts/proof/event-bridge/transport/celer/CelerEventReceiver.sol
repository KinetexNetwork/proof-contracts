// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventReceiver} from "../base/BaseEventReceiver.sol";

import {ICelerEventReceiver, CelerEventReceiverParams, IMessageBus} from "./interfaces/ICelerEventReceiver.sol";

contract CelerEventReceiver is ICelerEventReceiver, BaseEventReceiver {
    string public constant PROVIDER = "celer";
    IMessageBus public immutable CELER_BUS;
    uint32 public immutable CELER_SENDER_CHAIN;

    constructor(CelerEventReceiverParams memory params_) BaseEventReceiver(params_.eventHashStorage, params_.senderChain, params_.senderAddress) {
        if (params_.celerBus == address(0)) revert InvalidCelerBus();
        CELER_BUS = IMessageBus(params_.celerBus);
        CELER_SENDER_CHAIN = params_.celerSenderChain;
    }

    function executeMessage(address sender_, uint64 srcChainId_, bytes calldata message_, address) external payable returns (ExecutionStatus) {
        if (msg.sender != address(CELER_BUS) || srcChainId_ != CELER_SENDER_CHAIN || sender_ != SENDER_ADDRESS) revert UnauthorizedCelerReceive();
        _receivePayload(message_);
        return ExecutionStatus.Success;
    }
}
