import { ethers } from 'hardhat';
import { ZeroAddress } from 'ethers';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';

import { LOCAL_STATE_PROOF_VARIANT } from '../../../scripts/lib/contract/proof/local-state/variant';

import { TEST_CHAIN_ID, ANOTHER_CHAIN_ID } from '../../common/chainId';
import { MOCK_PROOF_VARIANT, mockHashEventProof } from '../../common/proofMock';
import { expectRevert } from '../../common/revert';
import { gasInfo } from '../../common/gas';
import { expectLog } from '../../common/log';

const EVENT_SIGNATURE = '0xE5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5';
const EVENT_ARG = '0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF';

describe('ProofVerifierRouterOwnedTest', function () {
  async function deployFixture() {
    const [ownerAccount, otherAccount] = await ethers.getSigners();

    const ProofVerifierMock = await ethers.getContractFactory('ProofVerifierMock');
    const proofVerifierMock0 = await ProofVerifierMock.deploy();
    const proofVerifierMock1 = await ProofVerifierMock.deploy();

    const proofVerifierMock0Address = await proofVerifierMock0.getAddress();
    const proofVerifierMock1Address = await proofVerifierMock1.getAddress();

    const ProofVerifierRouterOwned = await ethers.getContractFactory('ProofVerifierRouterOwned');
    const proofVerifierRouter = await ProofVerifierRouterOwned.deploy(ownerAccount.address);

    return {
      ownerAccount,
      otherAccount,
      proofVerifierMock0,
      proofVerifierMock1,
      proofVerifierMock0Address,
      proofVerifierMock1Address,
      proofVerifierRouter,
    };
  }

  it('Should not allow route by default', async function () {
    const { proofVerifierRouter } = await loadFixture(deployFixture);

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
  });

  it('Should not allow route edit for non-owner', async function () {
    const { proofVerifierRouter, proofVerifierMock0Address, otherAccount } = await loadFixture(deployFixture);

    await expectRevert(
      proofVerifierRouter.connect(otherAccount).setRouteVerifier(
        TEST_CHAIN_ID,
        MOCK_PROOF_VARIANT,
        proofVerifierMock0Address,
      ),
      { customError: `OwnableUnauthorizedAccount("${otherAccount.address}")` },
    );
  });

  it('Should allow route edit for owner', async function () {
    const { proofVerifierRouter, proofVerifierMock0Address } = await loadFixture(deployFixture);

    {
      const verifier = await proofVerifierRouter.proofVerifier(TEST_CHAIN_ID, MOCK_PROOF_VARIANT);
      expect(verifier).to.be.equal(ZeroAddress);
    }

    const { tx, receipt } = await gasInfo(
      'call setRouteVerifier (add new verifier)',
      await proofVerifierRouter.setRouteVerifier(
        TEST_CHAIN_ID,
        MOCK_PROOF_VARIANT,
        proofVerifierMock0Address,
      ),
    );
    expectLog({
      contract: proofVerifierRouter, tx, receipt, name: 'RouteVerifierUpdate', check: (data) => {
        expect(data.chain).to.be.equal(TEST_CHAIN_ID);
        expect(data.variant).to.be.equal(MOCK_PROOF_VARIANT);
        expect(data.oldVerifier).to.be.equal(ZeroAddress);
        expect(data.newVerifier).to.be.equal(proofVerifierMock0Address);
      },
    });

    {
      const verifier = await proofVerifierRouter.proofVerifier(TEST_CHAIN_ID, MOCK_PROOF_VARIANT);
      expect(verifier).to.be.equal(proofVerifierMock0Address);
    }
  });

  it('Should allow route edit from existing to new', async function () {
    const { proofVerifierRouter, proofVerifierMock0Address, proofVerifierMock1Address } = await loadFixture(deployFixture);

    await proofVerifierRouter.setRouteVerifier(
      TEST_CHAIN_ID,
      MOCK_PROOF_VARIANT,
      proofVerifierMock0Address,
    );

    {
      const verifier = await proofVerifierRouter.proofVerifier(TEST_CHAIN_ID, MOCK_PROOF_VARIANT);
      expect(verifier).to.be.equal(proofVerifierMock0Address);
    }

    const { tx, receipt } = await gasInfo(
      'call setRouteVerifier (update existing verifier)',
      await proofVerifierRouter.setRouteVerifier(
        TEST_CHAIN_ID,
        MOCK_PROOF_VARIANT,
        proofVerifierMock1Address,
      ),
    );
    expectLog({
      contract: proofVerifierRouter, tx, receipt, name: 'RouteVerifierUpdate', check: (data) => {
        expect(data.chain).to.be.equal(TEST_CHAIN_ID);
        expect(data.variant).to.be.equal(MOCK_PROOF_VARIANT);
        expect(data.oldVerifier).to.be.equal(proofVerifierMock0Address);
        expect(data.newVerifier).to.be.equal(proofVerifierMock1Address);
      },
    });

    {
      const verifier = await proofVerifierRouter.proofVerifier(TEST_CHAIN_ID, MOCK_PROOF_VARIANT);
      expect(verifier).to.be.equal(proofVerifierMock1Address);
    }
  });

  it('Should not allow route edit to same verifier', async function () {
    const { proofVerifierRouter, proofVerifierMock0Address } = await loadFixture(deployFixture);

    await proofVerifierRouter.setRouteVerifier(
      TEST_CHAIN_ID,
      MOCK_PROOF_VARIANT,
      proofVerifierMock0Address,
    );

    await expectRevert(
      proofVerifierRouter.setRouteVerifier(
        TEST_CHAIN_ID,
        MOCK_PROOF_VARIANT,
        proofVerifierMock0Address,
      ),
      { customError: `SameRouteVerifier(${TEST_CHAIN_ID}, ${MOCK_PROOF_VARIANT}, "${proofVerifierMock0Address}")` },
    );
  });

  it('Should allow different-route edits to same verifier', async function () {
    const { proofVerifierRouter, proofVerifierMock0Address } = await loadFixture(deployFixture);

    await proofVerifierRouter.setRouteVerifier(
      TEST_CHAIN_ID,
      MOCK_PROOF_VARIANT,
      proofVerifierMock0Address,
    );

    {
      const verifier = await proofVerifierRouter.proofVerifier(TEST_CHAIN_ID, MOCK_PROOF_VARIANT);
      expect(verifier).to.be.equal(proofVerifierMock0Address);
    }
    {
      const verifier = await proofVerifierRouter.proofVerifier(ANOTHER_CHAIN_ID, MOCK_PROOF_VARIANT);
      expect(verifier).to.be.equal(ZeroAddress);
    }
    {
      const verifier = await proofVerifierRouter.proofVerifier(ANOTHER_CHAIN_ID, LOCAL_STATE_PROOF_VARIANT);
      expect(verifier).to.be.equal(ZeroAddress);
    }

    const { tx, receipt } = await gasInfo(
      'call setRouteVerifier (add 2 new verifiers via multicall)',
      await proofVerifierRouter.multicall([
        proofVerifierRouter.interface.encodeFunctionData(
          'setRouteVerifier',
          [
            ANOTHER_CHAIN_ID,
            MOCK_PROOF_VARIANT,
            proofVerifierMock0Address,
          ],
        ),
        proofVerifierRouter.interface.encodeFunctionData(
          'setRouteVerifier',
          [
            ANOTHER_CHAIN_ID,
            LOCAL_STATE_PROOF_VARIANT,
            proofVerifierMock0Address,
          ],
        ),
      ]),
    );
    expectLog({
      contract: proofVerifierRouter, tx, receipt, name: 'RouteVerifierUpdate', check: (data) => {
        expect(data.chain).to.be.equal(ANOTHER_CHAIN_ID);
        expect(data.variant).to.be.equal(MOCK_PROOF_VARIANT);
        expect(data.oldVerifier).to.be.equal(ZeroAddress);
        expect(data.newVerifier).to.be.equal(proofVerifierMock0Address);
      },
    });
    expectLog({
      contract: proofVerifierRouter, tx, receipt, name: 'RouteVerifierUpdate', index: 1, check: (data) => {
        expect(data.chain).to.be.equal(ANOTHER_CHAIN_ID);
        expect(data.variant).to.be.equal(LOCAL_STATE_PROOF_VARIANT);
        expect(data.oldVerifier).to.be.equal(ZeroAddress);
        expect(data.newVerifier).to.be.equal(proofVerifierMock0Address);
      },
    });

    {
      const verifier = await proofVerifierRouter.proofVerifier(TEST_CHAIN_ID, MOCK_PROOF_VARIANT);
      expect(verifier).to.be.equal(proofVerifierMock0Address);
    }
    {
      const verifier = await proofVerifierRouter.proofVerifier(ANOTHER_CHAIN_ID, MOCK_PROOF_VARIANT);
      expect(verifier).to.be.equal(proofVerifierMock0Address);
    }
    {
      const verifier = await proofVerifierRouter.proofVerifier(ANOTHER_CHAIN_ID, LOCAL_STATE_PROOF_VARIANT);
      expect(verifier).to.be.equal(proofVerifierMock0Address);
    }
  });
});
