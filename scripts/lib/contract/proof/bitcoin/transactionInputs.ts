import { createBitWordArray } from './bitWordArray';

export const packTransactionInputs = (totalInputs: bigint, inputIndexes: bigint[]): bigint[] => {
  return createBitWordArray(totalInputs, inputIndexes);
};
