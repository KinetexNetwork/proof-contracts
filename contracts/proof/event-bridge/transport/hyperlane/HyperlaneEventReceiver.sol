// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventReceiver} from "../base/BaseEventReceiver.sol";

import {IHyperlaneEventReceiver, IMailbox, ISpecifiesInterchainSecurityModule, HyperlaneEventReceiverParams, IInterchainSecurityModule} from "./interfaces/IHyperlaneEventReceiver.sol";

contract HyperlaneEventReceiver is IHyperlaneEventReceiver, ISpecifiesInterchainSecurityModule, BaseEventReceiver {
    string public constant PROVIDER = "hyperlane";
    IMailbox public immutable HYPERLANE_MAILBOX;
    IInterchainSecurityModule public immutable HYPERLANE_ISM;
    uint32 public immutable HYPERLANE_SENDER_CHAIN;
    bytes32 public immutable HYPERLANE_SENDER_ADDRESS;

    constructor(HyperlaneEventReceiverParams memory params_) BaseEventReceiver(params_.eventHashStorage, params_.senderChain, params_.senderAddress) {
        if (params_.hyperlaneMailbox == address(0)) revert InvalidHyperlaneMailbox();
        HYPERLANE_MAILBOX = IMailbox(params_.hyperlaneMailbox);
        HYPERLANE_ISM = IInterchainSecurityModule(params_.hyperlaneIsm);
        HYPERLANE_SENDER_CHAIN = params_.hyperlaneSenderChain;
        HYPERLANE_SENDER_ADDRESS = params_.hyperlaneSenderAddress;
    }

    // prettier-ignore
    function interchainSecurityModule() external view returns (IInterchainSecurityModule) { return IInterchainSecurityModule(HYPERLANE_ISM); }

    function handle(uint32 origin_, bytes32 sender_, bytes calldata message_) external payable {
        if (msg.sender != address(HYPERLANE_MAILBOX) || origin_ != HYPERLANE_SENDER_CHAIN || sender_ != HYPERLANE_SENDER_ADDRESS)
            revert UnauthorizedHyperlaneReceive();
        _receivePayload(message_);
    }
}
