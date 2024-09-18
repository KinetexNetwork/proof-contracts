// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {RLPReader} from "@eth-optimism/contracts-bedrock/src/libraries/rlp/RLPReader.sol";

import {RLPReader as RLPReader2} from "solidity-rlp/contracts/RLPReader.sol";

library RLPReaderExt {
    function readAddress(RLPReader.RLPItem memory item_) internal pure returns (address) {
        return RLPReader2.toAddress(_toItem2(item_));
    }

    function readUint256(RLPReader.RLPItem memory item_) internal pure returns (uint256) {
        return RLPReader2.toUint(_toItem2(item_));
    }

    function readBytes32(RLPReader.RLPItem memory item_) internal pure returns (bytes32) {
        return bytes32(readUint256(item_));
    }

    function _toItem2(RLPReader.RLPItem memory item_) private pure returns (RLPReader2.RLPItem memory item) {
        // Both libraries have the same item structure under the hood
        assembly { item := item_ } // prettier-ignore
    }
}
