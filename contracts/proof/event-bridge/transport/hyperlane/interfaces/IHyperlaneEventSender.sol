// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventSender} from "../../base/interfaces/IBaseEventSender.sol";

import {IMailbox} from "./Hyperlane.sol";
import {HyperlaneEventSenderParams} from "./HyperlaneEventSenderParams.sol";

interface IHyperlaneEventSenderErrors {
    error InvalidHyperlaneMailbox();
}

interface IHyperlaneEventSenderViews {
    function HYPERLANE_MAILBOX() external view returns (IMailbox);

    function HYPERLANE_RECEIVER_CHAIN() external view returns (uint32);

    function HYPERLANE_RECEIVER_ADDRESS() external view returns (bytes32);
}

interface IHyperlaneEventSender is IBaseEventSender, IHyperlaneEventSenderErrors, IHyperlaneEventSenderViews {}
