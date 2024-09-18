// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {BaseEventSender} from "../base/BaseEventSender.sol";

import {IZetaChainEventSender, ZetaChainEventSenderParams, ZetaConnector, ZetaTokenConsumer, ZetaInterfaces} from "./interfaces/IZetaChainEventSender.sol";

contract ZetaChainEventSender is IZetaChainEventSender, BaseEventSender {
    using SafeERC20 for IERC20;

    string public constant PROVIDER = "zeta-chain";
    ZetaConnector public immutable ZETA_CHAIN_CONNECTOR;
    IERC20 public immutable ZETA_CHAIN_TOKEN;
    ZetaTokenConsumer public immutable ZETA_CHAIN_CONSUMER;
    // solhint-disable-next-line var-name-mixedcase
    bytes public ZETA_CHAIN_RECEIVER_ADDRESS; // Immutable

    constructor(ZetaChainEventSenderParams memory params_) BaseEventSender(params_.publisher, params_.receiverChain, params_.receiverAddress) {
        if (params_.zetaChainConnector == address(0)) revert InvalidZetaChainConnector();
        if (params_.zetaChainToken == address(0)) revert InvalidZetaChainToken();
        if (params_.zetaChainConsumer == address(0)) revert InvalidZetaChainConsumer();
        if (params_.zetaChainReceiverAddress.length == 0) revert InvalidZetaChainReceiverAddress();
        ZETA_CHAIN_CONNECTOR = ZetaConnector(params_.zetaChainConnector);
        ZETA_CHAIN_TOKEN = IERC20(params_.zetaChainToken);
        ZETA_CHAIN_CONSUMER = ZetaTokenConsumer(params_.zetaChainConsumer);
        ZETA_CHAIN_RECEIVER_ADDRESS = params_.zetaChainReceiverAddress;
    }

    function _sendPayload(bytes calldata payload_, address) internal override {
        uint256 zetaAmount = ZETA_CHAIN_CONSUMER.getZetaFromEth{value: msg.value}(address(this), 0);
        ZETA_CHAIN_TOKEN.safeIncreaseAllowance(address(ZETA_CHAIN_CONNECTOR), zetaAmount);

        // prettier-ignore
        ZetaInterfaces.SendInput memory input = ZetaInterfaces.SendInput({destinationChainId: RECEIVER_CHAIN, destinationAddress: ZETA_CHAIN_RECEIVER_ADDRESS, destinationGasLimit: 100_000, message: payload_, zetaValueAndGas: zetaAmount, zetaParams: abi.encode("")});
        // solhint-disable-next-line check-send-result
        ZETA_CHAIN_CONNECTOR.send(input);
    }
}
