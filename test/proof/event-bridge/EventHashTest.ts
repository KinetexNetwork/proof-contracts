import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';

import { calcEventHash } from '../../../scripts/lib/contract/utils/eventHash';

const EVENT_SIGNATURES = [
  '0xE5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5',
  '0xF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7',
  '0x1111111122222222333333334444444411111111222222223333333344444444',
  '0x6666666666666666666666666666666666666666666666666666666666666666',
  '0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF',
] as const;
const EVENT_ARG = '0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF';

describe('EventHashTest', function () {
  async function deployFixture() {
    const EventHashTest = await ethers.getContractFactory('EventHashTest');
    const eventHashTest = await EventHashTest.deploy();
    return { eventHashTest };
  }

  it('Should calc expected event hash #0', async function () {
    const { eventHashTest } = await loadFixture(deployFixture);

    const offlineHash = await calcEventHash(EVENT_SIGNATURES[0], EVENT_ARG);
    expect(offlineHash).to.be.equal('0xb5523a4f17bbe430b4dbe091b3598074d15565fe097d3f7dfbe96080075af6df');

    const onlineHash = await eventHashTest.calcEventHash(EVENT_SIGNATURES[0], EVENT_ARG);
    expect(onlineHash).to.be.equal(offlineHash);
  });

  it('Should calc expected event hash #1', async function () {
    const { eventHashTest } = await loadFixture(deployFixture);

    const offlineHash = await calcEventHash(EVENT_SIGNATURES[1], EVENT_ARG);
    expect(offlineHash).to.be.equal('0x1b8bf9a5eb4358e96e5d121df5306af056c4425e946e083112b6361671575de1');

    const onlineHash = await eventHashTest.calcEventHash(EVENT_SIGNATURES[1], EVENT_ARG);
    expect(onlineHash).to.be.equal(offlineHash);
  });

  it('Should calc expected event hash #2', async function () {
    const { eventHashTest } = await loadFixture(deployFixture);

    const offlineHash = await calcEventHash(EVENT_SIGNATURES[2], EVENT_ARG);
    expect(offlineHash).to.be.equal('0xb7812af23ddae316a22ac72c8ce0a34966e6a9a4836dc673a08eaa08db5a2dca');

    const onlineHash = await eventHashTest.calcEventHash(EVENT_SIGNATURES[2], EVENT_ARG);
    expect(onlineHash).to.be.equal(offlineHash);
  });

  it('Should calc expected event hash #3', async function () {
    const { eventHashTest } = await loadFixture(deployFixture);

    const offlineHash = await calcEventHash(EVENT_SIGNATURES[3], EVENT_ARG);
    expect(offlineHash).to.be.equal('0xfdf1d65f7c6703c8ff137405d6e4dfc9cb980ca4b22939ad1b092bf0e667e6ac');

    const onlineHash = await eventHashTest.calcEventHash(EVENT_SIGNATURES[3], EVENT_ARG);
    expect(onlineHash).to.be.equal(offlineHash);
  });

  it('Should calc expected event hash #4', async function () {
    const { eventHashTest } = await loadFixture(deployFixture);

    const offlineHash = await calcEventHash(EVENT_SIGNATURES[4], EVENT_ARG);
    expect(offlineHash).to.be.equal('0xb66bd9bcb7850e11a783e9e39751e2421486b709d45ec8b9858d6e241a5e2c95');

    const onlineHash = await eventHashTest.calcEventHash(EVENT_SIGNATURES[4], EVENT_ARG);
    expect(onlineHash).to.be.equal(offlineHash);
  });
});
