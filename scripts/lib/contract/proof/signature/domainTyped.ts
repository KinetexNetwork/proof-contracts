import { TypedDataDomain } from '../../../evm';

const SIGNATURE_PROOF_VERIFIER_DOMAIN_BASE: TypedDataDomain = {
  name: 'SignatureProofVerifier',
  version: '1',
};

export type EventProofVerifierDomainParams = Required<Pick<TypedDataDomain, 'chainId' | 'verifyingContract'>>;

export const createEventProofVerifierDomain = (params: EventProofVerifierDomainParams): TypedDataDomain => {
  const domain: TypedDataDomain = {
    ...SIGNATURE_PROOF_VERIFIER_DOMAIN_BASE,
    chainId: params.chainId,
    verifyingContract: params.verifyingContract,
  };
  return domain;
};
