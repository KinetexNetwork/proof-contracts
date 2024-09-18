import { encodeProofBase } from '../base/proofEncodeBase';

import { BITCOIN_PROOF_VARIANT } from './variant';

export interface SubmitOutputParams {
  transaction: string;
  outputs: bigint[];
}

export interface SubmitTransferParams {
  transaction: string;
  inputs: bigint[];
  inputAddressHash: string;
  outputs: bigint[];
  outputAddressHash: string;
  minAmount: bigint;
  timeData: bigint;
  blockHeader: string;
  merkleBranch: string[];
  merkleOrders: bigint;
}

export interface EncodeBitcoinProofParams {
  outputSubmits?: SubmitOutputParams[];
  transferSubmits?: SubmitTransferParams[];
  convertData?: string;
}

export const encodeBitcoinProof = async ({
  outputSubmits = [],
  transferSubmits = [],
  convertData = '0x',
}: EncodeBitcoinProofParams): Promise<string> => {
  const proofData = await encodeProofBase(BITCOIN_PROOF_VARIANT, {
    type: [
      {
        array: [
          'bytes', // transaction
          { array: 'uint256' }, // outputs
        ],
      },
      {
        array: [
          'bytes', // transaction
          { array: 'uint256' }, // inputs
          'bytes24', // inputAddressHash
          { array: 'uint256' }, // outputs
          'bytes24', // outputAddressHash
          'uint64', // minAmount
          'uint64', // timeData
          'bytes', // blockHeader
          { array: 'bytes32' }, // merkleBranch
          'uint256', // merkleOrders
        ],
      },
      'bytes', // convertData
    ],
    value: [
      outputSubmits.map((os) => [os.transaction, os.outputs]),
      transferSubmits.map((ts) => [
        ts.transaction,
        ts.inputs,
        ts.inputAddressHash,
        ts.outputs,
        ts.outputAddressHash,
        ts.minAmount,
        ts.timeData,
        ts.blockHeader,
        ts.merkleBranch,
        ts.merkleOrders,
      ]),
      convertData,
    ],
  });
  return proofData;
};
