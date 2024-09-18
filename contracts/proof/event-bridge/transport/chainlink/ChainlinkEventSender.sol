// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BaseEventSender} from "../base/BaseEventSender.sol";

import {IChainlinkEventSender, ChainlinkEventSenderParams, Client, IRouterClient} from "./interfaces/IChainlinkEventSender.sol";

contract ChainlinkEventSender is IChainlinkEventSender, BaseEventSender {
    string public constant PROVIDER = "chainlink";
    IRouterClient public immutable CHAINLINK_ROUTER;
    uint64 public immutable CHAINLINK_RECEIVER_CHAIN;

    constructor(ChainlinkEventSenderParams memory params_) BaseEventSender(params_.publisher, params_.receiverChain, params_.receiverAddress) {
        if (params_.chainlinkRouter == address(0)) revert InvalidChainlinkRouter();
        CHAINLINK_ROUTER = IRouterClient(params_.chainlinkRouter);
        CHAINLINK_RECEIVER_CHAIN = params_.chainlinkReceiverChain;
    }

    function _sendPayload(bytes calldata payload_, address) internal override {
        bytes memory args = Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 100_000}));
        // prettier-ignore
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({receiver: abi.encode(RECEIVER_ADDRESS), data: payload_, tokenAmounts: new Client.EVMTokenAmount[](0), extraArgs: args, feeToken: address(0)});
        CHAINLINK_ROUTER.ccipSend{value: msg.value}(CHAINLINK_RECEIVER_CHAIN, message);
    }
}
