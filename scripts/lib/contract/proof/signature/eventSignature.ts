import { ITypedDataSigner, TypedDataDomain } from '../../../evm';

import { isNotNull } from '../../../../helper/null';

import { createEventProofVerifierDomain, EventProofVerifierDomainParams } from './domainTyped';
import { SignatureProofEvent } from './event';
import { SIGNATURE_PROOF_EVENT_TYPE } from './eventTyped';
import { SIGNATURE_PROOF_VARIANT } from './variant';

export type CreateEventProofSignatureDomain = TypedDataDomain | EventProofVerifierDomainParams;

export const createEventProofSignature = async (
  domain: CreateEventProofSignatureDomain,
  event: SignatureProofEvent,
  signer: ITypedDataSigner,
): Promise<string> => {
  const { chainId, verifyingContract } = domain;
  if (isNotNull(chainId) && isNotNull(verifyingContract)) {
    domain = createEventProofVerifierDomain({ chainId, verifyingContract });
  }

  const signature = await signer.signTypedData(
    domain,
    SIGNATURE_PROOF_EVENT_TYPE,
    { ...event, variant: event.variant ?? SIGNATURE_PROOF_VARIANT },
  );
  return signature;
};
