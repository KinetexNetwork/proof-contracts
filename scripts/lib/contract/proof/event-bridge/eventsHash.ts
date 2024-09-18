import { evm } from '../../../evm';

// See `contracts/proof/event-bridge/EventBridgeHashLib.sol`

export const calcEventsHash = async (eventHashes: string[]): Promise<string> => {
  const eventsHashData = await evm.abiEncode([{ array: 'bytes32' }], [eventHashes]);
  const eventsHash = await evm.keccak256(eventsHashData);
  return eventsHash;
};
