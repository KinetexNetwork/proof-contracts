import { BIT_WORD_SIZE, setWordBit } from './bitWord';

export enum MerkleBranchOrder {
  Left = 'left',
  Right = 'right',
}

export const packMerkleBranchOrders = (orders: MerkleBranchOrder[]): bigint => {
  if (orders.length > BIT_WORD_SIZE) {
    throw new Error('Too many branch orders, cannot exceed 256 elements');
  }

  let packedOrders = 0n;
  for (let i = 0; i < orders.length; i++) {
    if (orders[i] === MerkleBranchOrder.Right) {
      packedOrders = setWordBit(packedOrders, i);
    }
  }
  return packedOrders;
};
