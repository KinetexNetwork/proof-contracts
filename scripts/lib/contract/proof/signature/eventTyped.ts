import { TypedDataFields } from '../../../evm';

export const SIGNATURE_PROOF_EVENT_TYPE: TypedDataFields = {
  ProofEvent: [
    { type: 'bytes32', name: 'sig' },
    { type: 'bytes32', name: 'arg' },
    { type: 'uint256', name: 'chain' },
    { type: 'address', name: 'caller' },
    { type: 'uint256', name: 'variant' },
  ],
};
