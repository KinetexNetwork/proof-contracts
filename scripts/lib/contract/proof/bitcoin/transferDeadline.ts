export const TRANSFER_SHOULD_EXIST_DEADLINE = 0n;

export type CreateTransferDeadlineParams = { shouldExist: true } | { shouldExist: false, submitDeadline: bigint };

export const createTransferDeadline = (params: CreateTransferDeadlineParams): bigint => {
  if (params.shouldExist) {
    return 0n; // Special deadline constant
  }

  return params.submitDeadline;
};
