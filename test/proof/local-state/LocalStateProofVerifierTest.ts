import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';

import { calcEventHash } from '../../../scripts/lib/contract/utils/eventHash';

import { expectRevert } from '../../common/revert';

const EVENT_SIGNATURES = [
  '0xE5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5',
  '0xF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7',
] as const;
const EVENT_ARG = '0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF';

describe('LocalStateProofVerifierTest', function () {
  async function deployFixture() {
    const [ownerAccount] = await ethers.getSigners();

    const BitAuthHashStorage = await ethers.getContractFactory('BitAuthHashStorage')
    const eventHashStorage = await BitAuthHashStorage.deploy([ownerAccount]);

    const LocalStateProofVerifier = await ethers.getContractFactory('LocalStateProofVerifier');
    const localStateProofVerifier = await LocalStateProofVerifier.deploy(eventHashStorage);

    return {
      eventHashStorage,
      localStateProofVerifier,
    };
  }

  it('Should not verify not stored event', async function () {
    const { localStateProofVerifier } = await loadFixture(deployFixture);

    await expectRevert(
      localStateProofVerifier.verifyHashEventProof(EVENT_SIGNATURES[0], EVENT_ARG, 0, '0x'),
      { customError: 'EventHashNotStored()', },
    );
  });

  it('Should verify stored event', async function () {
    const {
      eventHashStorage,
      localStateProofVerifier,
    } = await loadFixture(deployFixture);

    const receiveEventHash = await calcEventHash(EVENT_SIGNATURES[0], EVENT_ARG);
    await eventHashStorage.storeHash(receiveEventHash);

    await localStateProofVerifier.verifyHashEventProof(EVENT_SIGNATURES[0], EVENT_ARG, 0, '0x');
  });

  it('Should not verify event when different one stored', async function () {
    const {
      eventHashStorage,
      localStateProofVerifier,
    } = await loadFixture(deployFixture);

    const receiveEventHash = await calcEventHash(EVENT_SIGNATURES[0], EVENT_ARG);
    await eventHashStorage.storeHash(receiveEventHash);

    await expectRevert(
      localStateProofVerifier.verifyHashEventProof(EVENT_SIGNATURES[1], EVENT_ARG, 0, '0x'),
      { customError: 'EventHashNotStored()', },
    );
  });
});
