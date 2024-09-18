// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

import {EnvLib} from "../../utils/EnvLib.sol";

import {ILightClientProofVerifier, ILightClient} from "./interfaces/ILightClientProofVerifier.sol";
import {LightClientProofData} from "./interfaces/LightClientProofData.sol";

import {ReceiptLib} from "./ReceiptLib.sol";
import {HashEventLib} from "./HashEventLib.sol";

contract LightClientProofVerifier is ILightClientProofVerifier {
    uint256 public immutable CHAIN;
    ILightClient public immutable LIGHT_CLIENT;
    address public immutable BROADCASTER;
    uint256 public immutable MIN_DELAY;

    constructor(uint256 chain_, address lightClient_, address broadcaster_, uint256 minDelay_) {
        CHAIN = chain_;
        LIGHT_CLIENT = ILightClient(lightClient_);
        BROADCASTER = broadcaster_;
        MIN_DELAY = minDelay_;
    }

    function verifyHashEventProof(bytes32 sig_, bytes32 hash_, uint256 chain_, bytes calldata proof_) external view {
        if (chain_ != CHAIN) revert InvalidChain(chain_, CHAIN);

        LightClientProofData calldata data;
        assembly { data := add(proof_.offset, 64) } // prettier-ignore

        bytes32 headerRoot = _getValidHeaderRoot(data.srcSlot);
        ReceiptLib.verifyReceiptsRoot(data.receiptsRoot, data.receiptsRootProof, headerRoot, data.srcSlot, data.txSlot, chain_);

        HashEventLib.verifyHashEvent(data.receiptProof, data.receiptsRoot, data.txIndexRLPEncoded, data.logIndex, BROADCASTER, sig_, hash_);
    }

    function _getValidHeaderRoot(uint256 srcSlot_) private view returns (bytes32 headerRoot) {
        if (!LIGHT_CLIENT.consistent()) revert LightClientInconsistent();

        uint256 slotTimestamp = LIGHT_CLIENT.timestamps(srcSlot_);
        if (slotTimestamp == 0) revert NoSlotTimestamp(srcSlot_);
        uint256 elapsedTime = EnvLib.timeNow() - slotTimestamp;
        if (elapsedTime < MIN_DELAY) revert SlotNotSettled(srcSlot_, elapsedTime, MIN_DELAY);

        headerRoot = LIGHT_CLIENT.headers(srcSlot_);
        if (headerRoot == bytes32(0)) revert NoHeaderRoot(srcSlot_);
    }
}
