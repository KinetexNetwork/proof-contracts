// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

library Base58 {
    bytes private constant ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    function encode(bytes memory data_) internal pure returns (string memory) {
        unchecked {
            uint256 size = data_.length;
            uint256 zeroCount;
            while (zeroCount < size && data_[zeroCount] == 0) zeroCount++;
            size = zeroCount + ((size - zeroCount) * 8351) / 6115 + 1;
            bytes memory slot = new bytes(size);
            uint32 carry;
            int256 m;
            int256 high = int256(size) - 1;
            for (uint256 i = 0; i < data_.length; i++) {
                m = int256(size - 1);
                for (carry = uint8(data_[i]); m > high || carry != 0; m--) {
                    carry = carry + 256 * uint8(slot[uint256(m)]);
                    slot[uint256(m)] = bytes1(uint8(carry % 58));
                    carry /= 58;
                }
                high = m;
            }
            uint256 n;
            for (n = zeroCount; n < size && slot[n] == 0; n++) {}
            size = slot.length - (n - zeroCount);
            bytes memory out = new bytes(size);
            for (uint256 i = 0; i < size; i++) out[i] = ALPHABET[uint8(slot[i + n - zeroCount])];
            return string(out);
        }
    }
}
