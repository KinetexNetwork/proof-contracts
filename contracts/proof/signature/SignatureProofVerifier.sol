// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {ISignatureProofVerifier} from "./interfaces/ISignatureProofVerifier.sol";

contract SignatureProofVerifier is ISignatureProofVerifier, EIP712, Ownable2Step {
    bytes32 private constant EVENT_TYPEHASH = keccak256("ProofEvent(bytes32 sig,bytes32 arg,uint256 chain,address caller,uint256 variant)");

    constructor(address initialOwner_) EIP712("SignatureProofVerifier", "1") Ownable(initialOwner_) {}

    function verifyHashEventProof(bytes32 sig_, bytes32 arg_, uint256 chain_, bytes calldata proof_) external view {
        uint256 variant;
        bytes calldata signature;
        assembly {
            variant := calldataload(proof_.offset)
            signature.length := calldataload(add(proof_.offset, 64))
            signature.offset := add(proof_.offset, 96)
        }

        bytes32 eventHash = _hashTypedDataV4(keccak256(abi.encode(EVENT_TYPEHASH, sig_, arg_, chain_, _msgSender(), variant)));
        if (!SignatureChecker.isValidSignatureNow(owner(), eventHash, signature)) revert InvalidEventSignature();
    }
}
