// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventReceiver} from "../../base/interfaces/IBaseEventReceiver.sol";

import {IAxelarExecutable, IAxelarGateway} from "./Axelar.sol";
import {AxelarEventReceiverParams} from "./AxelarEventReceiverParams.sol";

interface IAxelarEventReceiverErrors {
    error InvalidAxelarGateway();
    error InvalidAxelarSenderChain();
    error InvalidAxelarSenderAddress();
    error UnauthorizedAxelarReceive();
    error NotApprovedByAxelarGateway();
}

interface IAxelarEventReceiverViews {
    function AXELAR_GATEWAY() external view returns (IAxelarGateway);

    function AXELAR_SENDER_CHAIN_HASH() external view returns (bytes32);

    function AXELAR_SENDER_ADDRESS_HASH() external view returns (bytes32);
}

interface IAxelarEventReceiver is IBaseEventReceiver, IAxelarEventReceiverErrors, IAxelarEventReceiverViews, IAxelarExecutable {}
