// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IBaseEventSender} from "../../base/interfaces/IBaseEventSender.sol";

import {ZetaConnector, ZetaTokenConsumer, ZetaInterfaces} from "./ZetaChain.sol";
import {ZetaChainEventSenderParams} from "./ZetaChainEventSenderParams.sol";

interface IZetaChainEventSenderErrors {
    error InvalidZetaChainConnector();
    error InvalidZetaChainToken();
    error InvalidZetaChainConsumer();
    error InvalidZetaChainReceiverAddress();
}

interface IZetaChainEventSenderViews {
    function ZETA_CHAIN_CONNECTOR() external view returns (ZetaConnector);

    function ZETA_CHAIN_TOKEN() external view returns (IERC20);

    function ZETA_CHAIN_CONSUMER() external view returns (ZetaTokenConsumer);

    function ZETA_CHAIN_RECEIVER_ADDRESS() external view returns (bytes memory);
}

interface IZetaChainEventSender is IBaseEventSender, IZetaChainEventSenderErrors, IZetaChainEventSenderViews {}
