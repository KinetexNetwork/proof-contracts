// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

import {TokenPermitter} from "../../../permit/TokenPermitter.sol";

import {EventBridgeAdapterFossil} from "../adapter/EventBridgeAdapterFossil.sol";

import {SenderFossil, SenderFossilConfig} from "../reporter/SenderFossil.sol";
import {EventMultiSender} from "../reporter/EventMultiSender.sol";

import {IEventBridgeRelayerFossil} from "./interfaces/IEventBridgeRelayerFossil.sol";

// prettier-ignore
contract EventBridgeRelayerFossil is IEventBridgeRelayerFossil, EventBridgeAdapterFossil, SenderFossil, EventMultiSender, TokenPermitter, Multicall {
    constructor(address[] memory writers_, uint8 threshold_, SenderFossilConfig[] memory senderConfigs_, address nativeToken_)
        EventBridgeAdapterFossil(writers_, threshold_) SenderFossil(senderConfigs_) EventMultiSender(nativeToken_) {}

    function relayEvent(bytes32 eventHash_, uint256 chain_, bytes32[] calldata sends_) external {
        _relayEvent(eventHash_, chain_, sends_, false);
    }

    function relayEventNative(bytes32 eventHash_, uint256 chain_, bytes32[] calldata sends_) external payable {
        _relayEvent(eventHash_, chain_, sends_, true);
    }

    function _relayEvent(bytes32 eventHash_, uint256 chain_, bytes32[] calldata sends_, bool nativePayment_) private {
        if (!eventReceived(eventHash_)) revert EventNotReceived();
        _sendPayload(eventHash_, chain_, sends_, nativePayment_);
    }

    function _selectSender(uint256 chain_, uint256 index_) internal view override returns (address) { return _getSender(chain_, index_); }
}
