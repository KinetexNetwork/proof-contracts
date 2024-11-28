import { ITypedDataSigner } from '../../../evm';

import { encodeProofBase } from '../base/proofEncodeBase';

import { SignatureProofEvent } from './event';
import { createEventProofSignature, CreateEventProofSignatureDomain } from './eventSignature';
import { SIGNATURE_PROOF_VARIANT } from './variant';

export interface CreateSignatureParams {
  domain: CreateEventProofSignatureDomain,
  event: SignatureProofEvent,
  signer: ITypedDataSigner,
};

export const encodeSignatureProof = async (
  signature: string | CreateSignatureParams,
  variant = SIGNATURE_PROOF_VARIANT,
): Promise<string> => {
  if (typeof signature !== 'string') {
    variant = signature.event.variant ?? variant;
    signature = await createEventProofSignature(signature.domain, signature.event, signature.signer);
  }

  const proofData = await encodeProofBase(variant, {
    type: 'bytes',
    value: signature,
  });
  return proofData;
};
