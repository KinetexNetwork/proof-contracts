import { createBitWordArray } from './bitWordArray';

export const packTransactionOutputs = (totalOutputs: bigint, outputIndexes: bigint[]): bigint[] => {
  return createBitWordArray(totalOutputs, outputIndexes);
};
