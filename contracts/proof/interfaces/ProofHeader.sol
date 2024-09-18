// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.24;

// Every proof (`bytes`) is encoded as: `abi.encode((..., ...), (ProofHeader, SpecificProofData))`.
// The `ProofHeader` structure contains helper data for routers to select appropriate proof verifier
// that is aware of how to decode the main data of the proof (i.e. example `SpecificProofData` above).

struct ProofHeader {
    uint256 variant;
}
