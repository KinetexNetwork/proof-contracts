import { bufferToHex, hexToBuffer } from './hexBuffer';

export const swapEndian = (hex: string): string => {
  const bytes = hexToBuffer(hex);
  bytes.reverse();
  const swappedHex = bufferToHex(bytes);
  return swappedHex;
};
