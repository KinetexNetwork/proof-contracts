// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

library ReceiptLib {
    error InvalidTargetSlot(uint256 srcSlot, uint256 txSlot);
    error InvalidReceiptsRootProof(bytes32 headerRoot, bytes32 restoredHeaderRoot);
    error InvalidMerkleBranch(uint256 index, uint256 maxIndex);

    uint256 private constant HISTORICAL_ROOTS_LIMIT = 16777216;
    uint256 private constant SLOTS_PER_HISTORICAL_ROOT = 8192;

    function verifyReceiptsRoot(
        bytes32 receiptsRoot_,
        bytes32[] memory receiptsRootProof_,
        bytes32 headerRoot_,
        uint64 srcSlot_,
        uint64 txSlot_,
        uint256 srcChain_
    ) internal pure {
        // Index represents a global node position inside a Merkle tree.
        // The position calculation is based on "path" it takes to get from tree root to target node.
        // Path can be thought of as series of "jumps" between intermediate nodes using relative gindexes.
        // Nodes are organized as binary tree, where gindex of root is 0. Assume there is node "X" with gindex "x",
        // and node "Y" in "X" subtree with relative gindex "y". Then gindex of node "Y" in entire tree
        // is calculated as "x * 2 ** floor(log2(y)) + y - 2 ** floor(log2(y))".
        uint256 index;
        if (srcSlot_ == txSlot_) {
            uint256 denebForkSlot = _getDenebSlot(srcChain_);

            index = 11; // gindex = 11
            index = index * 2 ** 5 + 24; // gindex = 56
            index = index * 2 ** (txSlot_ < denebForkSlot ? 4 : 5) + 3; // gindex = 19/35 (capella/deneb)
        } else if (srcSlot_ - txSlot_ <= SLOTS_PER_HISTORICAL_ROOT) {
            uint256 denebForkSlot = _getDenebSlot(srcChain_);

            index = 11; // gindex = 11
            index = index * 2 ** 5 + 6; // gindex = 38
            index = index * SLOTS_PER_HISTORICAL_ROOT + (txSlot_ % SLOTS_PER_HISTORICAL_ROOT);
            index = index * 2 ** 5 + 24; // gindex = 56
            index = index * 2 ** (txSlot_ < denebForkSlot ? 4 : 5) + 3; // gindex = 19/35 (capella/deneb)
        } else if (txSlot_ < srcSlot_) {
            uint256 capellaForkSlot = _getCapellaSlot(srcChain_);

            // In Bellatrix we use state.historical_roots, in Capella we use state.historical_summaries
            // We use < here because capellaForkSlot is the last slot processed using Bellatrix logic;
            // the last batch in state.historical_roots contains the 8192 slots *before* capellaForkSlot.
            uint256 stateToHistoricalGIndex = txSlot_ < capellaForkSlot ? 7 : 27;

            // The list state.historical_summaries is empty at the beginning of Capella
            uint256 historicalListIndex = txSlot_ < capellaForkSlot
                ? txSlot_ / SLOTS_PER_HISTORICAL_ROOT
                : (txSlot_ - capellaForkSlot) / SLOTS_PER_HISTORICAL_ROOT;

            index = 8 + 3;
            index = index * 2 ** 5 + stateToHistoricalGIndex;
            index = index * 2 + 0;
            index = index * HISTORICAL_ROOTS_LIMIT + historicalListIndex;
            index = index * 2 + 1;
            index = index * SLOTS_PER_HISTORICAL_ROOT + (txSlot_ % SLOTS_PER_HISTORICAL_ROOT);
            index = index * 2 ** 9 + 387;
        } else {
            revert InvalidTargetSlot(srcSlot_, txSlot_);
        }

        bytes32 restoredMerkleRoot = _restoreMerkleRoot(receiptsRoot_, index, receiptsRootProof_);
        if (restoredMerkleRoot != headerRoot_) revert InvalidReceiptsRootProof(headerRoot_, restoredMerkleRoot);
    }

    // `_get<fork>Slot` functions return `<fork>_FORK_EPOCH` * `SLOTS_PER_EPOCH` for corresponding `chain_`

    function _getCapellaSlot(uint256 chain_) private pure returns (uint256) {
        // Ethereum (Mainnet)
        // https://github.com/ethereum/consensus-specs/blob/dev/specs/capella/fork.md
        if (chain_ == 1) return 6209536;

        // Gnosis (Mainnet)
        if (chain_ == 100) return 10379264;

        // Goerli (Testnet of Ethereum)
        // https://blog.ethereum.org/2023/03/08/goerli-shapella-announcement
        // https://github.com/eth-clients/goerli/blob/main/prater/config.yaml#L43
        if (chain_ == 5) return 5193728;

        // Chiado (Testnet of Gnosis)
        if (chain_ == 10200) return 3907584;

        // Fallback to Bellatrix fork logic
        return type(uint256).max;
    }

    function _getDenebSlot(uint256 chain_) private pure returns (uint256) {
        // Ethereum (Mainnet)
        // https://github.com/ethereum/consensus-specs/blob/dev/specs/deneb/fork.md
        if (chain_ == 1) return 8626176;

        // Gnosis (Mainnet)
        // https://github.com/gnosischain/configs/blob/main/mainnet/config.yaml
        if (chain_ == 100) return 14237696;

        // Goerli (Testnet of Ethereum)
        // https://github.com/eth-clients/goerli/blob/main/prater/config.yaml
        if (chain_ == 5) return 7413760;

        // Chiado (Testnet of Gnosis)
        // https://github.com/gnosischain/configs/blob/main/chiado/config.yaml
        if (chain_ == 10200) return 8265728;

        // Fallback to Bellatrix fork logic
        return type(uint256).max;
    }

    function _restoreMerkleRoot(bytes32 leaf_, uint256 index_, bytes32[] memory branch_) private pure returns (bytes32) {
        uint256 maxIndex = 2 ** (branch_.length + 1);
        if (index_ >= maxIndex) revert InvalidMerkleBranch(index_, maxIndex);

        uint256 i = 0;
        while (index_ != 1) {
            leaf_ = sha256(index_ % 2 == 1 ? bytes.concat(branch_[i], leaf_) : bytes.concat(leaf_, branch_[i]));
            index_ /= 2;
            i++;
        }
        return leaf_;
    }
}
