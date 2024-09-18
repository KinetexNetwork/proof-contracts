// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {EnvLib} from "../../../../utils/EnvLib.sol";

import {BaseEventReceiver} from "../base/BaseEventReceiver.sol";

import {IZetaChainEventReceiver, ZetaChainEventReceiverParams, ZetaInterfaces, ZetaConnector} from "./interfaces/IZetaChainEventReceiver.sol";

contract ZetaChainEventReceiver is IZetaChainEventReceiver, BaseEventReceiver {
    string public constant PROVIDER = "zeta-chain";
    ZetaConnector public immutable ZETA_CHAIN_CONNECTOR;
    bytes32 public immutable ZETA_CHAIN_SENDER_ADDRESS_HASH;

    constructor(ZetaChainEventReceiverParams memory params_) BaseEventReceiver(params_.eventHashStorage, params_.senderChain, params_.senderAddress) {
        if (params_.zetaChainConnector == address(0)) revert InvalidZetaChainConnector();
        if (params_.zetaChainSenderAddress.length == 0) revert InvalidZetaChainSenderAddress();
        ZETA_CHAIN_CONNECTOR = ZetaConnector(params_.zetaChainConnector);
        ZETA_CHAIN_SENDER_ADDRESS_HASH = keccak256(params_.zetaChainSenderAddress);
    }

    function onZetaMessage(ZetaInterfaces.ZetaMessage calldata zm_) external {
        // Auth adapted from "ZetaInteractor" contract's "isValidMessageCall" modifier
        // prettier-ignore
        if (msg.sender != address(ZETA_CHAIN_CONNECTOR) || zm_.sourceChainId != SENDER_CHAIN || keccak256(zm_.zetaTxSenderAddress) != ZETA_CHAIN_SENDER_ADDRESS_HASH) revert UnauthorizedZetaChainReceive();
        _receivePayload(zm_.message);
    }

    function onZetaRevert(ZetaInterfaces.ZetaRevert calldata zr_) external {
        // Auth adapted from "ZetaInteractor" contract's "isValidRevertCall" modifier
        // prettier-ignore
        if (msg.sender != address(ZETA_CHAIN_CONNECTOR) || zr_.sourceChainId != EnvLib.thisChain() || zr_.zetaTxSenderAddress != address(this)) revert UnauthorizedZetaChainReceiveRevert();
        _receivePayload(zr_.message);
    }
}
