import { encodeProofBase } from '../base/proofEncodeBase';

import { LIGHT_CLIENT_PROOF_VARIANT } from './variant';

export interface EncodeLightClientProofParams {
  srcSlot: bigint;
  txSlot: bigint;
  receiptsRootProof: string[];
  receiptsRoot: string;
  receiptProof: string[];
  txIndexRLPEncoded: string;
  logIndex: bigint;
}

export const encodeLightClientProof = async (params: EncodeLightClientProofParams): Promise<string> => {
  const proofData = await encodeProofBase(LIGHT_CLIENT_PROOF_VARIANT, {
    type: [
      'uint64', // srcSlot
      'uint64', // txSlot
      { array: 'bytes32' }, // receiptsRootProof
      'bytes32', // receiptsRoot
      { array: 'bytes' }, // receiptProof
      'bytes', // txIndexRLPEncoded
      'uint256', // logIndex
    ],
    value: [
      params.srcSlot,
      params.txSlot,
      params.receiptsRootProof,
      params.receiptsRoot,
      params.receiptProof,
      params.txIndexRLPEncoded,
      params.logIndex,
    ],
  });
  return proofData;
};
