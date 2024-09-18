// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file

pragma solidity 0.8.24;

interface IAxelarGateway {
    function callContract(string calldata destinationChain, string calldata contractAddress, bytes calldata payload) external;

    function validateContractCall(bytes32 commandId, string calldata sourceChain, string calldata sourceAddress, bytes32 payloadHash) external returns (bool);
}

interface IAxelarExecutable {
    function gateway() external view returns (IAxelarGateway);

    function execute(bytes32 commandId, string calldata sourceChain, string calldata sourceAddress, bytes calldata payload) external;
}

interface IAxelarGasService {
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;
}
