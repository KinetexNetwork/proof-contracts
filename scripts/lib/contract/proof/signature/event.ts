export interface SignatureProofEvent {
  sig: string,
  arg: string,
  chain: bigint,
  caller: string,
  variant?: bigint,
}
