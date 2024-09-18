// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IBitcoinTransferConverter} from "../../../proof/bitcoin/interfaces/IBitcoinTransferConverter.sol";
import {BitcoinProofData} from "../../../proof/bitcoin/interfaces/BitcoinProofData.sol";

contract BitcoinTransferConverterMock is IBitcoinTransferConverter {
    function convertToTransfer(bytes32, bytes32, bytes calldata proof_) external pure returns (bytes32 transferHash, uint256 deadline) {
        BitcoinProofData calldata data;
        assembly { data := add(proof_.offset, 64) } // prettier-ignore
        (transferHash, deadline) = abi.decode(data.convertData, (bytes32, uint256));
    }
}
