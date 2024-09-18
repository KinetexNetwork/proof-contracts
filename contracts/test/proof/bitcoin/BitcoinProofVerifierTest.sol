// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {BitcoinProofVerifier, BitcoinTransferLib} from "../../../proof/bitcoin/BitcoinProofVerifier.sol";

contract BitcoinProofVerifierTest is BitcoinProofVerifier {
    constructor(address lightClient_, address transferConverter_) BitcoinProofVerifier(lightClient_, transferConverter_) {}

    function createOutputData(uint64 amount_, bytes24 addressHash_) external pure returns (uint256) {
        return _createOutputData(amount_, addressHash_);
    }

    function calcAddressHash(string memory address_) external pure returns (bytes24) {
        return BitcoinTransferLib.calcAddressHash(address_);
    }

    function outputDataAmount(uint256 data_) external pure returns (uint64) {
        return _outputDataAmount(data_);
    }

    function outputDataAddressHash(uint256 data_) external pure returns (bytes24) {
        return _outputDataAddressHash(data_);
    }

    function verifyTransferIo(
        bytes calldata transaction_,
        uint256[] calldata inputs_,
        string memory inputAddress_,
        uint256[] calldata outputs_,
        string memory outputAddress_,
        uint64 minAmount_
    ) external view {
        _verifyTransferIo(
            transaction_,
            inputs_,
            BitcoinTransferLib.calcAddressHash(inputAddress_),
            outputs_,
            BitcoinTransferLib.calcAddressHash(outputAddress_),
            minAmount_
        );
    }

    function calcTransferHash(bytes24 inputAddressHash_, bytes24 outputAddressHash_, uint64 minAmount_, uint64 timeData_) external pure returns (bytes32) {
        return BitcoinTransferLib.calcTransferHash(inputAddressHash_, outputAddressHash_, minAmount_, timeData_);
    }
}
