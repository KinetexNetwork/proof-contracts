export const BIT_WORD_SIZE = 256n;

export const setWordBit = (word: bigint, at: bigint | number): bigint => {
  return word | (1n << BigInt(at));
};
