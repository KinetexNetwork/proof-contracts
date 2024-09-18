// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventSender} from "../base/BaseEventSender.sol";

import {IAxelarEventSender, AxelarEventSenderParams, IAxelarGateway, IAxelarGasService} from "./interfaces/IAxelarEventSender.sol";

contract AxelarEventSender is IAxelarEventSender, BaseEventSender {
    string public constant PROVIDER = "axelar";
    IAxelarGateway public immutable AXELAR_GATEWAY;
    IAxelarGasService public immutable AXELAR_GAS_SERVICE;
    // solhint-disable-next-line var-name-mixedcase
    string public AXELAR_RECEIVER_CHAIN; // Immutable
    // solhint-disable-next-line var-name-mixedcase
    string public AXELAR_RECEIVER_ADDRESS; // Immutable

    constructor(AxelarEventSenderParams memory params_) BaseEventSender(params_.publisher, params_.receiverChain, params_.receiverAddress) {
        if (params_.axelarGateway == address(0)) revert InvalidAxelarGateway();
        if (params_.axelarGasService == address(0)) revert InvalidAxelarGasService();
        if (bytes(params_.axelarReceiverChain).length == 0) revert InvalidAxelarReceiverChain();
        if (bytes(params_.axelarReceiverAddress).length == 0) revert InvalidAxelarReceiverAddress();
        AXELAR_GATEWAY = IAxelarGateway(params_.axelarGateway);
        AXELAR_GAS_SERVICE = IAxelarGasService(params_.axelarGasService);
        AXELAR_RECEIVER_CHAIN = params_.axelarReceiverChain;
        AXELAR_RECEIVER_ADDRESS = params_.axelarReceiverAddress;
    }

    function _sendPayload(bytes calldata payload_, address refundAddress_) internal override {
        AXELAR_GAS_SERVICE.payNativeGasForContractCall{value: msg.value}(
            address(this),
            AXELAR_RECEIVER_CHAIN,
            AXELAR_RECEIVER_ADDRESS,
            payload_,
            refundAddress_
        );
        AXELAR_GATEWAY.callContract(AXELAR_RECEIVER_CHAIN, AXELAR_RECEIVER_ADDRESS, payload_);
    }
}
