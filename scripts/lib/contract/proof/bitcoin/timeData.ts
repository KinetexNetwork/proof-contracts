const MAX_UINT32 = (1n << 32n) - 1n;

export const encodeTimeData = (start: bigint, duration: bigint): bigint => {
  if (start < 0n || start > MAX_UINT32) {
    throw new Error('Invalid start part of time data');
  }

  if (duration < 0n || duration > MAX_UINT32) {
    throw new Error('Invalid duration part of time data');
  }

  const timeData = start | (duration << 32n);
  return timeData;
};
