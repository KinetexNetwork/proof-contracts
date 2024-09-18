// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventReceiver} from "../base/BaseEventReceiver.sol";

import {IAxelarEventReceiver, AxelarEventReceiverParams, IAxelarGateway} from "./interfaces/IAxelarEventReceiver.sol";

contract AxelarEventReceiver is IAxelarEventReceiver, BaseEventReceiver {
    string public constant PROVIDER = "axelar";
    IAxelarGateway public immutable AXELAR_GATEWAY;
    bytes32 public immutable AXELAR_SENDER_CHAIN_HASH;
    bytes32 public immutable AXELAR_SENDER_ADDRESS_HASH;

    constructor(AxelarEventReceiverParams memory params_) BaseEventReceiver(params_.eventHashStorage, params_.senderChain, params_.senderAddress) {
        if (params_.axelarGateway == address(0)) revert InvalidAxelarGateway();
        if (bytes(params_.axelarSenderChain).length == 0) revert InvalidAxelarSenderChain();
        if (bytes(params_.axelarSenderAddress).length == 0) revert InvalidAxelarSenderAddress();
        AXELAR_GATEWAY = IAxelarGateway(params_.axelarGateway);
        AXELAR_SENDER_CHAIN_HASH = keccak256(bytes(params_.axelarSenderChain));
        AXELAR_SENDER_ADDRESS_HASH = keccak256(bytes(params_.axelarSenderAddress));
    }

    // prettier-ignore
    function gateway() external view returns (IAxelarGateway) { return AXELAR_GATEWAY; }

    function execute(bytes32 commandId_, string calldata sourceChain_, string calldata sourceAddress_, bytes calldata payload_) external {
        // prettier-ignore
        if (keccak256(bytes(sourceChain_)) != AXELAR_SENDER_CHAIN_HASH || keccak256(bytes(sourceAddress_)) != AXELAR_SENDER_ADDRESS_HASH) revert UnauthorizedAxelarReceive();
        // From original `AxelarExecutable` contract auth implementation
        if (!AXELAR_GATEWAY.validateContractCall(commandId_, sourceChain_, sourceAddress_, keccak256(payload_))) revert NotApprovedByAxelarGateway();
        _receivePayload(payload_);
    }
}
