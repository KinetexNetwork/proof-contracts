// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IBitAuthHashStorage} from "./interfaces/IBitAuthHashStorage.sol";

import {BitAuth} from "./BitAuth.sol";

contract BitAuthHashStorage is IBitAuthHashStorage, BitAuth {
    mapping(bytes32 hash => uint256) public hashReport;

    constructor(address[] memory writers_) BitAuth(writers_) {}

    function storeHash(bytes32 hash_) external {
        if (!canStore(msg.sender)) revert UnauthorizedStore(msg.sender);
        hashReport[hash_] |= (1 << writerIndex(msg.sender));
    }

    function hasHashStore(bytes32 hash_) public view returns (bool) {
        return hashReport[hash_] != 0;
    }

    function hashStoreCount(bytes32 hash_) public view returns (uint256) {
        return _countBits(hashReport[hash_]);
    }

    function isHashStoredBy(bytes32 hash_, address account_) public view returns (bool) {
        if (!canStore(account_)) return false;
        return (hashReport[hash_] & (1 << writerIndex(account_))) != 0;
    }

    function _countBits(uint256 value_) private pure returns (uint16 bits) {
        while (value_ != 0) {
            if (value_ % 2 != 0) { unchecked { bits++; } } // prettier-ignore
            value_ >>= 1;
        }
    }
}
