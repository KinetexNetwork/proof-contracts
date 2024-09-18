import { evm } from '../../../evm';

import { Send } from './send';

const MAX_UINT248 = (1n << 248n) - 1n;

export const encodeSends = async (sends: Send[]): Promise<string[]> => {
  const sendData = await Promise.all(sends.map(encodeSend));
  return sendData;
};

export const encodeSend = async (send: Send): Promise<string> => {
  const sendData = fillSenderBits(send.sender) | fillValueBits(send.value);
  return await evm.toHexBytes(sendData, 32);
};

const fillSenderBits = (sender: number): bigint => {
  if (sender < 0 || sender > 255) {
    throw new Error('Invalid sender');
  }
  return BigInt(sender) << 248n;
};

const fillValueBits = (value: bigint): bigint => {
  if (value < 0n || value > MAX_UINT248) {
    throw new Error('Invalid value');
  }
  return value;
};
