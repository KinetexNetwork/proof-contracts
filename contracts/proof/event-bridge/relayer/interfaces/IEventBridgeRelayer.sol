// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {ISharedHashStorage} from "../../../../storage/interfaces/ISharedHashStorage.sol";

interface IEventBridgeRelayer is ISharedHashStorage {
    function relayEvent(bytes32 eventHash, uint256 chain, bytes32[] calldata sends) external;

    function relayEventNative(bytes32 eventHash, uint256 chain, bytes32[] calldata sends) external payable;
}
