import { encodeProofBase } from '../base/proofEncodeBase';

import { CONTROL_CONFIRM_PROOF_VARIANT } from './variant';

export const encodeControlConfirmProof = async (): Promise<string> => {
  const proofData = await encodeProofBase(CONTROL_CONFIRM_PROOF_VARIANT);
  return proofData;
};
