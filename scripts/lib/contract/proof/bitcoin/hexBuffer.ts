export const hexToBuffer = (hex: string): Buffer => {
  if (hex.startsWith('0x') || hex.startsWith('0X')) {
    hex = hex.slice(2);
  }

  const buffer = Buffer.from(hex, 'hex');
  return buffer;
};

export const bufferToHex = (buffer: Buffer): string => {
  const hex = `0x${buffer.toString('hex')}`;
  return hex;
};
