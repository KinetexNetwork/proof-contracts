// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

interface IEventBridgeAdapter {
    function eventReceived(bytes32 eventHash) external view returns (bool);
}
