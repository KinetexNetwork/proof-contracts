import { isNotNull, isNull } from '../../../../helper/null';

import { swapEndian } from './endian';
import { calcHash256 } from './hash';
import { bufferToHex, hexToBuffer } from './hexBuffer';
import { MerkleBranchOrder } from './merkleBranchOrder';

export interface MerkleProof {
  branch: string[];
  orders: MerkleBranchOrder[];
}

export const createMerkleProof = async (txid: string, txids: string[], checkRoot?: string): Promise<MerkleProof> => {
  if (txids.length < 1) {
    throw new Error('Merkle proof construction requires at least one element in TXID list');
  }

  const txidIndex = txids.indexOf(txid);
  if (txidIndex < 0) {
    throw new Error('Merkle proof can only be constructed for transaction included in TXID list');
  }

  txid = swapEndian(txid);
  txids = txids.map((txid) => swapEndian(txid));

  const proof: MerkleProof = {
    branch: [],
    orders: [],
  };

  let stepHash = txid;
  let stepHashes = txids;
  while (stepHashes.length > 1) {
    let nextHash: string | undefined;
    const nextHashes: string[] = [];
    for (let i = 0; i < stepHashes.length; i += 2) {
      const leftData = stepHashes[i];
      const rightData = i + 1 === stepHashes.length ? leftData : stepHashes[i + 1];
      const data = bufferToHex(Buffer.concat([hexToBuffer(leftData), hexToBuffer(rightData)]));
      const hash = await calcHash256(data);
      nextHashes.push(hash);

      if (leftData === stepHash || rightData === stepHash) {
        const useLeft = rightData === stepHash;
        const leaf = useLeft ? leftData : rightData;
        const order = useLeft ? MerkleBranchOrder.Left : MerkleBranchOrder.Right;
        proof.branch.push(leaf);
        proof.orders.push(order);
        nextHash = hash;
      }
    }

    if (isNull(nextHash) || nextHashes.length === 0) {
      throw new Error('Failed to construct Merkle proof (unexpected state)');
    }

    stepHash = nextHash;
    stepHashes = nextHashes;
  }

  if (isNotNull(checkRoot)) {
    checkRoot = swapEndian(checkRoot);
    if (stepHashes.length !== 1 || stepHashes[0] !== stepHash || stepHash !== checkRoot) {
      throw new Error('Merkle proof root check mismatch');
    }
  }

  return proof;
};
