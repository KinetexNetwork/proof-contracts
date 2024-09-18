// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file

pragma solidity 0.8.24;

interface IMailbox {
    function dispatch(uint32 destinationDomain, bytes32 recipientAddress, bytes calldata messageBody) external payable returns (bytes32 messageId);
}

interface IHyperlaneHandler {
    function handle(uint32 origin, bytes32 sender, bytes calldata message) external payable;
}

interface IInterchainSecurityModule {
    function moduleType() external view returns (uint8);

    function verify(bytes calldata metadata, bytes calldata message) external returns (bool);
}

interface ISpecifiesInterchainSecurityModule {
    function interchainSecurityModule() external view returns (IInterchainSecurityModule);
}
