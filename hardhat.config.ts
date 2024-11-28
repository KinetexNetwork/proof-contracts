import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-solhint';
import 'hardhat-contract-sizer';

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.24',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1_000_000,
      },
    },
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: true,
    runOnCompile: true,
    strict: true,
    only: [
      'contracts/proof/router/ProofVerifierRouterFossil.sol',
      'contracts/proof/router/ProofVerifierRouterOwned.sol',
      'contracts/proof/event-bridge/EventBridgeProofVerifier.sol',
      'contracts/proof/event-bridge/reporter/EventBridgeReporterFossil.sol',
      'contracts/proof/event-bridge/adapter/EventBridgeAdapterFossil.sol',
      'contracts/proof/event-bridge/relayer/EventBridgeRelayerFossil.sol',
      'contracts/proof/event-bridge/transport/axelar/AxelarEventReceiver.sol',
      'contracts/proof/event-bridge/transport/axelar/AxelarEventSender.sol',
      'contracts/proof/event-bridge/transport/celer/CelerEventReceiver.sol',
      'contracts/proof/event-bridge/transport/celer/CelerEventSender.sol',
      'contracts/proof/event-bridge/transport/chainlink/ChainlinkEventReceiver.sol',
      'contracts/proof/event-bridge/transport/chainlink/ChainlinkEventSender.sol',
      'contracts/proof/event-bridge/transport/connext/ConnextEventReceiver.sol',
      'contracts/proof/event-bridge/transport/connext/ConnextEventSender.sol',
      'contracts/proof/event-bridge/transport/hyperlane/HyperlaneEventReceiver.sol',
      'contracts/proof/event-bridge/transport/hyperlane/HyperlaneEventSender.sol',
      'contracts/proof/event-bridge/transport/wormhole/WormholeEventReceiver.sol',
      'contracts/proof/event-bridge/transport/wormhole/WormholeEventSender.sol',
      'contracts/proof/event-bridge/transport/layer-zero/LayerZeroEventReceiver.sol',
      'contracts/proof/event-bridge/transport/layer-zero/LayerZeroEventSender.sol',
      'contracts/proof/event-bridge/transport/zeta-chain/ZetaChainEventReceiver.sol',
      'contracts/proof/event-bridge/transport/zeta-chain/ZetaChainEventSender.sol',
      'contracts/proof/local-state/LocalStateProofVerifier.sol',
      'contracts/proof/control-confirm/ControlConfirmProofVerifier.sol',
      'contracts/proof/signature/SignatureProofVerifier.sol',
      'contracts/proof/bitcoin/BitcoinProofVerifier.sol',
      'contracts/proof/light-client/LightClientProofVerifier.sol',
    ],
  },
};

export default config;
