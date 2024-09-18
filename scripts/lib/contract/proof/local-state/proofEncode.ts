import { encodeProofBase } from '../base/proofEncodeBase';

import { LOCAL_STATE_PROOF_VARIANT } from './variant';

export const encodeLocalStateProof = async (): Promise<string> => {
  const proofData = await encodeProofBase(LOCAL_STATE_PROOF_VARIANT);
  return proofData;
};
