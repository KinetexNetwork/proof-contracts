import { encodeProofBase } from '../base/proofEncodeBase';

import { EVENT_BRIDGE_PROOF_VARIANT } from './variant';

export const encodeEventBridgeProof = async (): Promise<string> => {
  const proofData = await encodeProofBase(EVENT_BRIDGE_PROOF_VARIANT);
  return proofData;
};
