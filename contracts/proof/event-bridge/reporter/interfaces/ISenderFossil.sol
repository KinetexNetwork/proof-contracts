// SPDX-License-Identifier: BUSL-1.1

// solhint-disable no-unused-import, one-contract-per-file, no-empty-blocks, func-name-mixedcase

pragma solidity 0.8.24;

import {SenderFossilConfig} from "./SenderFossilConfig.sol";

interface ISenderFossilErrors {
    error SenderListEmpty(uint256 index);
    error SenderListTooLarge(uint256 index);
    error ChainSendersOverride(uint256 index);
    error InvalidSender();
    error NoSenderRoute();
}

interface ISenderFossilViews {
    function SENDER(uint256 chain, uint256 index) external view returns (address);
}

interface ISenderFossil is ISenderFossilErrors, ISenderFossilViews {}
