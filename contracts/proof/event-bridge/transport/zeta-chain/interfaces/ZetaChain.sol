// SPDX-License-Identifier: BUSL-1.1

// solhint-disable one-contract-per-file

pragma solidity 0.8.24;

interface ZetaInterfaces {
    struct SendInput {
        uint256 destinationChainId;
        bytes destinationAddress;
        uint256 destinationGasLimit;
        bytes message;
        uint256 zetaValueAndGas;
        bytes zetaParams;
    }

    struct ZetaMessage {
        bytes zetaTxSenderAddress;
        uint256 sourceChainId;
        address destinationAddress;
        uint256 zetaValue;
        bytes message;
    }

    struct ZetaRevert {
        address zetaTxSenderAddress;
        uint256 sourceChainId;
        bytes destinationAddress;
        uint256 destinationChainId;
        uint256 remainingZetaValue;
        bytes message;
    }
}

interface ZetaConnector {
    function send(ZetaInterfaces.SendInput calldata input) external;
}

interface ZetaReceiver {
    function onZetaMessage(ZetaInterfaces.ZetaMessage calldata zetaMessage) external;

    function onZetaRevert(ZetaInterfaces.ZetaRevert calldata zetaRevert) external;
}

interface ZetaTokenConsumer {
    function getZetaFromEth(address destinationAddress, uint256 minAmountOut) external payable returns (uint256);
}
