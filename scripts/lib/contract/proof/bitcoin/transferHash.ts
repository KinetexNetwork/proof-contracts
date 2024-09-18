import { evm } from '../../../evm';

import { calcAddressHash } from './addressHash';
import { bufferToHex, hexToBuffer } from './hexBuffer';
import { encodeTimeData } from './timeData';

const MAX_UINT64 = (1n << 64n) - 1n;

const encodeMinAmountHex = async (minAmount: bigint): Promise<string> => {
  if (minAmount < 0n || minAmount > MAX_UINT64) {
    throw new Error('Invalid min amount value');
  }

  const minAmountHex = await evm.toHexBytes(minAmount, 8);
  return minAmountHex;
};

const encodeTimeDataHex = async (start: bigint, duration: bigint): Promise<string> => {
  const timeData = encodeTimeData(start, duration);
  const timeDataHex = await evm.toHexBytes(timeData, 8);
  return timeDataHex;
};

export const calcTransferHash = async (
  inputAddress: string,
  outputAddress: string,
  minAmount: bigint,
  start: bigint,
  duration: bigint,
): Promise<string> => {
  const [minAmountHex, inputAddressHash, outputAddressHash, timeDataHex] = await Promise.all([
    encodeMinAmountHex(minAmount),
    calcAddressHash(inputAddress),
    calcAddressHash(outputAddress),
    encodeTimeDataHex(start, duration),
  ]);

  const data = bufferToHex(
    Buffer.concat([
      hexToBuffer(inputAddressHash),
      hexToBuffer(outputAddressHash),
      hexToBuffer(minAmountHex),
      hexToBuffer(timeDataHex),
    ]),
  );
  const hash = await evm.keccak256(data);
  return hash;
};
