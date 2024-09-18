import { evm } from '../../../evm';

import { ProofData } from './proofData';

export const encodeProofBase = async (variant: bigint, ...data: ProofData[]): Promise<string> => {
  const proofData = await evm.abiEncode(
    [['uint256'], ...data.map((d) => d.type)],
    [[variant], ...data.map((d) => d.value)],
  );
  return proofData;
};
