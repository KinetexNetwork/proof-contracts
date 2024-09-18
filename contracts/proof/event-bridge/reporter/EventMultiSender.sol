// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IEventSender} from "../transport/interfaces/IEventSender.sol";

import {IEventMultiSender, IERC20Native} from "./interfaces/IEventMultiSender.sol";

abstract contract EventMultiSender is IEventMultiSender {
    using SafeERC20 for IERC20Native;

    IERC20Native public immutable NATIVE_TOKEN;

    constructor(address nativeToken_) {
        if (nativeToken_ == address(0)) revert InvalidNativeToken();
        NATIVE_TOKEN = IERC20Native(nativeToken_);
    }

    receive() external payable {}

    function _selectSender(uint256 chain_, uint256 index_) internal view virtual returns (address);

    function _sendPayload(bytes32 eventHash_, uint256 chain_, bytes32[] calldata sends_, bool nativePayment_) internal {
        uint256 paymentValue = 0;
        for (uint256 i = 0; i < sends_.length; i++) paymentValue += uint256(sends_[i] << 8) >> 8;

        if (nativePayment_) {
            if (msg.value < paymentValue) revert InsufficientMessageValue();
        } else {
            NATIVE_TOKEN.safeTransferFrom(msg.sender, address(this), paymentValue);
            NATIVE_TOKEN.withdraw(paymentValue);
        }

        bytes memory payload = abi.encode(eventHash_);
        for (uint256 i = 0; i < sends_.length; i++) {
            (uint256 senderIndex, uint256 sendValue) = (uint256(sends_[i] >> 248), uint256(sends_[i] << 8) >> 8);
            address sender = _selectSender(chain_, senderIndex);
            IEventSender(sender).sendPayload{value: sendValue}(payload, msg.sender);
        }
    }
}
