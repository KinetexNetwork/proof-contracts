// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IBitAuth} from "./interfaces/IBitAuth.sol";

abstract contract BitAuth is IBitAuth {
    uint256 public immutable TOTAL_WRITERS;
    // solhint-disable-next-line var-name-mixedcase
    mapping(address writer => uint256) private _WRITER_DATA; // Immutable

    constructor(address[] memory writers_) {
        if (writers_.length > 255) revert WriterListTooLarge();
        TOTAL_WRITERS = writers_.length;
        for (uint256 i = 0; i < writers_.length; i++) {
            if (writers_[i] == address(0)) revert InvalidWriter(i);
            if (_WRITER_DATA[writers_[i]] != 0) revert WriterOverride(i);
            _WRITER_DATA[writers_[i]] = i | (1 << 255); // Valid writer bit
        }
    }

    function canStore(address account_) public view returns (bool) {
        return _WRITER_DATA[account_] != 0;
    }

    function writerIndex(address account_) public view returns (uint8) {
        return uint8(_WRITER_DATA[account_]);
    }
}
