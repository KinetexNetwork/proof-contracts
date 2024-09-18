// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IBaseEventSender} from "../../base/interfaces/IBaseEventSender.sol";

import {IAxelarGateway, IAxelarGasService} from "./Axelar.sol";
import {AxelarEventSenderParams} from "./AxelarEventSenderParams.sol";

interface IAxelarEventSenderErrors {
    error InvalidAxelarGateway();
    error InvalidAxelarGasService();
    error InvalidAxelarReceiverChain();
    error InvalidAxelarReceiverAddress();
}

interface IAxelarEventSenderViews {
    function AXELAR_GATEWAY() external view returns (IAxelarGateway);

    function AXELAR_GAS_SERVICE() external view returns (IAxelarGasService);

    function AXELAR_RECEIVER_CHAIN() external view returns (string memory);

    function AXELAR_RECEIVER_ADDRESS() external view returns (string memory);
}

interface IAxelarEventSender is IBaseEventSender, IAxelarEventSenderErrors, IAxelarEventSenderViews {}
