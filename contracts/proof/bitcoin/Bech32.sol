// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

library Bech32 {
    bytes private constant ALPHABET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l";
    bytes private constant SEPARATOR = "1";

    function encode(bytes memory hrp_, uint8 version_, bytes memory program_) internal pure returns (string memory) {
        bytes memory data = bytes.concat(bytes1(version_), _toFiveBits(program_));
        data = bytes.concat(data, _createChecksum(hrp_, data, version_ != 0));
        for (uint256 i = 0; i < data.length; i++) data[i] = ALPHABET[uint8(data[i])];
        return string(bytes.concat(hrp_, SEPARATOR, data));
    }

    function _toFiveBits(bytes memory data_) private pure returns (bytes memory result) {
        result = new bytes(_fiveBitsLength(data_.length));
        uint256 acc = 0;
        uint256 bits = 0;
        uint256 cursor = 0;
        for (uint256 i = 0; i < data_.length; i++) {
            uint256 value = uint8(data_[i]);
            acc = ((acc << 8) | value) & 4095;
            bits += 8;
            while (bits >= 5) {
                bits -= 5;
                result[cursor] = bytes1(uint8((acc >> bits) & 31));
                cursor++;
            }
        }
        if (bits > 0) result[cursor] = bytes1(uint8((acc << (5 - bits)) & 31));
    }

    function _fiveBitsLength(uint256 eightBitsLength_) private pure returns (uint256 length) {
        length = (eightBitsLength_ / 5) * 8;
        uint256 remainder = eightBitsLength_ % 5;
        if (remainder == 1) return length + 2;
        if (remainder == 2) return length + 4;
        if (remainder == 3) return length + 5;
        if (remainder == 4) return length + 7;
    }

    function _createChecksum(bytes memory hrp_, bytes memory data_, bool m_) private pure returns (bytes memory checksum) {
        bytes memory values = bytes.concat(_hrpExpand(hrp_), data_, new bytes(6));
        uint256 mod = _polymod(values) ^ (m_ ? 0x2BC830A3 : 1);
        checksum = new bytes(6);
        for (uint256 p = 0; p < 6; p++) checksum[p] = bytes1(uint8((mod >> (5 * (5 - p))) & 0x1F));
    }

    function _polymod(bytes memory data_) private pure returns (uint256) {
        uint32[5] memory GENERATOR = [0x3B6A57B2, 0x26508E6D, 0x1EA119FA, 0x3D4233DD, 0x2A1462B3];
        uint256 chk = 1;
        for (uint256 p = 0; p < data_.length; p++) {
            uint256 top = chk >> 25;
            chk = ((chk & 0x1FFFFFF) << 5) ^ uint256(uint8(data_[p]));
            for (uint256 i = 0; i < 5; i++) if ((top >> i) & 1 == 1) chk ^= GENERATOR[i];
        }
        return chk;
    }

    function _hrpExpand(bytes memory hrp_) private pure returns (bytes memory result) {
        result = new bytes(hrp_.length + hrp_.length + 1);
        for (uint256 p = 0; p < hrp_.length; p++) result[p] = hrp_[p] >> 5;
        result[hrp_.length] = 0;
        for (uint256 p = 0; p < hrp_.length; p++) result[p + hrp_.length + 1] = bytes1(uint8(hrp_[p] & 0x1F));
    }
}
