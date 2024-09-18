import { evm } from '../../../evm';

import { bufferToHex } from './hexBuffer';

export const calcAddressHash = async (address: string): Promise<string> => {
  const addressBytes = Buffer.from(address, 'utf-8');
  const addressHex = bufferToHex(addressBytes);
  const fullHash = await evm.keccak256(addressHex);
  const addressHash = fullHash.slice(0, 50); // First 24 bytes
  return addressHash;
};
