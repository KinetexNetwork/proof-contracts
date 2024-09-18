// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {IBitcoinLightClient} from "../../../proof/bitcoin/interfaces/IBitcoinLightClient.sol";

contract BitcoinLightClientMock is IBitcoinLightClient {
    mapping(bytes32 blockHash => bool) public blockConfirmed;

    function setBlockConfirmed(bytes32 blockHash_, bool confirmed_) external {
        blockConfirmed[blockHash_] = confirmed_;
    }
}
