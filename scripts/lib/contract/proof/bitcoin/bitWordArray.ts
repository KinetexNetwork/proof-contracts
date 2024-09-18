import { BIT_WORD_SIZE, setWordBit } from './bitWord';

export const createBitWordArray = (totalItems: bigint, enabledItems: bigint[]): bigint[] => {
  let totalWords = totalItems / BIT_WORD_SIZE;
  if (totalItems % BIT_WORD_SIZE > 0) {
    totalWords++;
  }

  const words = Array<bigint>(Number(totalWords)).fill(0n);
  for (const enabledItem of enabledItems) {
    if (enabledItem >= totalItems) {
      throw new Error('Index is out of range defined by total number of bit items');
    }

    const wordIndex = Number(enabledItem / BIT_WORD_SIZE);
    let word = words[wordIndex];
    word = setWordBit(word, enabledItem % BIT_WORD_SIZE);
    words[wordIndex] = word;
  }
  return words;
};
