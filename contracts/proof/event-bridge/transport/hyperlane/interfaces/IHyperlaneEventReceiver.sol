// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventReceiver} from "../../base/interfaces/IBaseEventReceiver.sol";

import {IHyperlaneHandler, IMailbox, IInterchainSecurityModule, ISpecifiesInterchainSecurityModule} from "./Hyperlane.sol";
import {HyperlaneEventReceiverParams} from "./HyperlaneEventReceiverParams.sol";

interface IHyperlaneEventReceiverErrors {
    error InvalidHyperlaneMailbox();
    error UnauthorizedHyperlaneReceive();
}

interface IHyperlaneEventReceiverViews {
    function HYPERLANE_MAILBOX() external view returns (IMailbox);

    function HYPERLANE_ISM() external view returns (IInterchainSecurityModule);

    function HYPERLANE_SENDER_CHAIN() external view returns (uint32);

    function HYPERLANE_SENDER_ADDRESS() external view returns (bytes32);
}

interface IHyperlaneEventReceiver is IBaseEventReceiver, IHyperlaneEventReceiverErrors, IHyperlaneEventReceiverViews, IHyperlaneHandler {}
