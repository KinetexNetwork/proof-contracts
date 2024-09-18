// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

library BitcoinTransferLib {
    // keccak256("Any address, one transaction") - first 24 bytes
    bytes24 internal constant ANY_BITCOIN_ADDRESS_HASH = 0x0680750672a95924ec2b7a0673ab32636ddf3de097759cfb;

    function calcAddressHash(string memory address_) internal pure returns (bytes24) {
        return bytes24(keccak256(bytes(address_)));
    }

    function calcTransferHash(bytes24 inputAddressHash_, bytes24 outputAddressHash_, uint64 minAmount_, uint64 timeData_) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(inputAddressHash_, outputAddressHash_, minAmount_, timeData_));
    }
}
