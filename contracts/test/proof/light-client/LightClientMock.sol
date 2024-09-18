// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {ILightClient} from "../../../proof/light-client/interfaces/ILightClient.sol";

import {EnvLib} from "../../../utils/EnvLib.sol";

contract LightClientMock is ILightClient {
    bool public consistent;
    mapping(uint256 => bytes32) public headers;
    mapping(uint256 => uint256) public timestamps;

    function setConsistent() external {
        consistent = true;
    }

    function setHeader(uint256 slot_, bytes32 headerRoot_) external {
        headers[slot_] = headerRoot_;
    }

    function setTimestamp(uint256 slot_) external {
        timestamps[slot_] = EnvLib.timeNow();
    }
}
