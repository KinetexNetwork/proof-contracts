import { encodeProofBase } from '../../scripts/lib/contract/proof/base/proofEncodeBase';

export const MOCK_PROOF_VARIANT = 133713371337n;

export const mockHashEventProof = async (sig: string, hash: string, chain: bigint): Promise<string> => {
  const proofData = await encodeProofBase(
    MOCK_PROOF_VARIANT,
    {
      type: [
        'bytes32',
        'bytes32',
        'uint256',
      ],
      value: [
        sig,
        hash,
        chain,
      ],
    });
  return proofData;
};
