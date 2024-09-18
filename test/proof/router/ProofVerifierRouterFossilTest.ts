import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';

import { VerifierFossilConfigStruct } from '../../../typechain-types/contracts/proof/router/ProofVerifierRouterFossil';

import { LOCAL_STATE_PROOF_VARIANT } from '../../../scripts/lib/contract/proof/local-state/variant';
import { encodeLocalStateProof } from '../../../scripts/lib/contract/proof/local-state/proofEncode';

import { EVENT_BRIDGE_PROOF_VARIANT } from '../../../scripts/lib/contract/proof/event-bridge/variant';
import { encodeEventBridgeProof } from '../../../scripts/lib/contract/proof/event-bridge/proofEncode';

import { TEST_CHAIN_ID, OTHER_CHAIN_ID } from '../../common/chainId';
import { MOCK_PROOF_VARIANT, mockHashEventProof } from '../../common/proofMock';
import { expectRevert } from '../../common/revert';

const EVENT_SIGNATURE = '0xE5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5';
const EVENT_ARG = '0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF';

describe('ProofVerifierRouterFossilTest', function () {
  async function deployFixture() {
    const ProofVerifierMock = await ethers.getContractFactory('ProofVerifierMock');
    const proofVerifierMock0 = await ProofVerifierMock.deploy();
    const proofVerifierMock1 = await ProofVerifierMock.deploy();
    const proofVerifierMock2 = await ProofVerifierMock.deploy();

    const verifierConfigs: VerifierFossilConfigStruct[] = [
      {
        chain: TEST_CHAIN_ID,
        variant: LOCAL_STATE_PROOF_VARIANT,
        verifier: proofVerifierMock0,
      },
      {
        chain: TEST_CHAIN_ID,
        variant: EVENT_BRIDGE_PROOF_VARIANT,
        verifier: proofVerifierMock1,
      },
      {
        chain: OTHER_CHAIN_ID,
        variant: EVENT_BRIDGE_PROOF_VARIANT,
        verifier: proofVerifierMock2,
      },
    ];

    const ProofVerifierRouterFossil = await ethers.getContractFactory('ProofVerifierRouterFossil');
    const proofVerifierRouter = await ProofVerifierRouterFossil.deploy(verifierConfigs);

    return {
      proofVerifierRouter,
      proofVerifierMock0,
      proofVerifierMock1,
      proofVerifierMock2,
    };
  }

  it('Should not verify proof for non-existing mock variant route', async function () {
    const {
      proofVerifierRouter,
      proofVerifierMock0,
      proofVerifierMock1,
      proofVerifierMock2,
    } = await loadFixture(deployFixture);

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }

    // Mock proof has variant "0" which is not routed in config
    const proof = await mockHashEventProof(
      EVENT_SIGNATURE,
      EVENT_ARG,
      TEST_CHAIN_ID,
    );

    await expectRevert(
      proofVerifierRouter.verifyHashEventProof(
        EVENT_SIGNATURE,
        EVENT_ARG,
        TEST_CHAIN_ID,
        proof,
      ),
      { customError: `NoVerifierRoute(${TEST_CHAIN_ID}, ${MOCK_PROOF_VARIANT})` },
    );

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
  });

  it('Should not verify proof for non-existing local state variant route', async function () {
    const {
      proofVerifierRouter,
      proofVerifierMock0,
      proofVerifierMock1,
      proofVerifierMock2,
    } = await loadFixture(deployFixture);

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }

    const proof = await encodeLocalStateProof();

    await expectRevert(
      proofVerifierRouter.verifyHashEventProof(
        EVENT_SIGNATURE,
        EVENT_ARG,
        OTHER_CHAIN_ID,
        proof,
      ),
      { customError: `NoVerifierRoute(${OTHER_CHAIN_ID}, ${LOCAL_STATE_PROOF_VARIANT})` },
    );

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
  });

  it('Should verify proof for existing route 0', async function () {
    const {
      proofVerifierRouter,
      proofVerifierMock0,
      proofVerifierMock1,
      proofVerifierMock2,
    } = await loadFixture(deployFixture);

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }

    const proof = await encodeLocalStateProof();

    await proofVerifierMock0.setExpectedVariant(LOCAL_STATE_PROOF_VARIANT);

    await proofVerifierRouter.verifyHashEventProof(
      EVENT_SIGNATURE,
      EVENT_ARG,
      TEST_CHAIN_ID,
      proof,
    );

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(1);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
  });

  it('Should verify proof for existing route 1', async function () {
    const {
      proofVerifierRouter,
      proofVerifierMock0,
      proofVerifierMock1,
      proofVerifierMock2,
    } = await loadFixture(deployFixture);

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }

    const proof = await encodeEventBridgeProof();

    await proofVerifierMock1.setExpectedVariant(EVENT_BRIDGE_PROOF_VARIANT);

    await proofVerifierRouter.verifyHashEventProof(
      EVENT_SIGNATURE,
      EVENT_ARG,
      TEST_CHAIN_ID,
      proof,
    );

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(1);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
  });

  it('Should verify proof for existing route 2', async function () {
    const {
      proofVerifierRouter,
      proofVerifierMock0,
      proofVerifierMock1,
      proofVerifierMock2,
    } = await loadFixture(deployFixture);

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(0);
    }

    const proof = await encodeEventBridgeProof();

    await proofVerifierMock2.setExpectedVariant(EVENT_BRIDGE_PROOF_VARIANT);

    await proofVerifierRouter.verifyHashEventProof(
      EVENT_SIGNATURE,
      EVENT_ARG,
      OTHER_CHAIN_ID,
      proof,
    );

    {
      const count = await proofVerifierMock0.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock1.verifiedProofCount();
      expect(count).to.be.equal(0);
    }
    {
      const count = await proofVerifierMock2.verifiedProofCount();
      expect(count).to.be.equal(1);
    }
  });
});
