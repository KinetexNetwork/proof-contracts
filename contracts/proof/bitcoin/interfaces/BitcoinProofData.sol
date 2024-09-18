// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {SubmitOutputParams} from "./SubmitOutputParams.sol";
import {SubmitTransferParams} from "./SubmitTransferParams.sol";

struct BitcoinProofData {
    SubmitOutputParams[] outputSubmits;
    SubmitTransferParams[] transferSubmits;
    bytes convertData; // Extra data for transfer converter
}
