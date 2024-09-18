// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

import {TokenPermitter} from "../../../permit/TokenPermitter.sol";

import {IEventBridgeReporterFossil} from "./interfaces/IEventBridgeReporterFossil.sol";

import {EventBridgeReporter} from "./EventBridgeReporter.sol";
import {SenderFossil, SenderFossilConfig} from "./SenderFossil.sol";

contract EventBridgeReporterFossil is IEventBridgeReporterFossil, EventBridgeReporter, SenderFossil, TokenPermitter, Multicall {
    // prettier-ignore
    constructor(address eventHashStorage_, address nativeToken_, SenderFossilConfig[] memory senderConfigs_)
        EventBridgeReporter(eventHashStorage_, nativeToken_) SenderFossil(senderConfigs_) {}

    // prettier-ignore
    function _selectSender(uint256 chain_, uint256 index_) internal view override returns (address) { return _getSender(chain_, index_); }
}
