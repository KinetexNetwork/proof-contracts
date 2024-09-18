// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

struct ZetaChainEventSenderParams {
    address publisher;
    uint256 receiverChain;
    address receiverAddress;
    address zetaChainConnector;
    address zetaChainToken;
    address zetaChainConsumer;
    bytes zetaChainReceiverAddress;
}
