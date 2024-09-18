import { evm } from '../../../evm';

export const calcHash256 = async (hex: string): Promise<string> => {
  return await evm.sha256(await evm.sha256(hex));
};
