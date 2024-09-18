// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {ISenderFossil, SenderFossilConfig} from "./interfaces/ISenderFossil.sol";

abstract contract SenderFossil is ISenderFossil {
    // solhint-disable-next-line var-name-mixedcase
    mapping(uint256 chain => mapping(uint256 index => address)) public SENDER; // Immutable

    constructor(SenderFossilConfig[] memory senderConfigs_) {
        for (uint256 i = 0; i < senderConfigs_.length; i++) {
            SenderFossilConfig memory sc = senderConfigs_[i];
            if (SENDER[sc.chain][0] != address(0)) revert ChainSendersOverride(i);
            if (sc.senders.length == 0) revert SenderListEmpty(i);
            if (sc.senders.length > 255) revert SenderListTooLarge(i);
            for (uint256 j = 0; j < sc.senders.length; j++) {
                if (sc.senders[j] == address(0)) revert InvalidSender();
                SENDER[sc.chain][j] = sc.senders[j];
            }
        }
    }

    function _getSender(uint256 chain_, uint256 index_) internal view returns (address sender) {
        sender = SENDER[chain_][index_];
        if (sender == address(0)) revert NoSenderRoute();
    }
}
