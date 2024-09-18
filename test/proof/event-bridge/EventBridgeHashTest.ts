import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';

import { calcEventsHash } from '../../../scripts/lib/contract/proof/event-bridge/eventsHash';

describe('EventBridgeHashTest', function () {
  async function deployFixture() {
    const EventBridgeHashTest = await ethers.getContractFactory('EventBridgeHashTest');
    const eventBridgeHashTest = await EventBridgeHashTest.deploy();
    return { eventBridgeHashTest };
  }

  it('Should calc expected hash of 0 events', async function () {
    const { eventBridgeHashTest } = await loadFixture(deployFixture);

    const eventHashes: string[] = [];

    const offlineHash = await calcEventsHash(eventHashes);
    expect(offlineHash).to.be.equal('0x569e75fc77c1a856f6daaf9e69d8a9566ca34aa47f9133711ce065a571af0cfd');

    const onlineHash = await eventBridgeHashTest.calcEventsHash(eventHashes);
    expect(onlineHash).to.be.equal(offlineHash);
  });

  it('Should calc expected hash of 1 event', async function () {
    const { eventBridgeHashTest } = await loadFixture(deployFixture);

    const eventHashes = [
      '0xb5523a4f17bbe430b4dbe091b3598074d15565fe097d3f7dfbe96080075af6df',
    ];

    const offlineHash = await calcEventsHash(eventHashes);
    expect(offlineHash).to.be.equal('0x1fd89d7c00b3a79c8c272bebfeee1ddfba718e355df4aa3b5310d563c787b94a');

    const onlineHash = await eventBridgeHashTest.calcEventsHash(eventHashes);
    expect(onlineHash).to.be.equal(offlineHash);
  });

  it('Should calc expected hash of 2 events', async function () {
    const { eventBridgeHashTest } = await loadFixture(deployFixture);

    const eventHashes = [
      '0xb5523a4f17bbe430b4dbe091b3598074d15565fe097d3f7dfbe96080075af6df',
      '0x1b8bf9a5eb4358e96e5d121df5306af056c4425e946e083112b6361671575de1',
    ];

    const offlineHash = await calcEventsHash(eventHashes);
    expect(offlineHash).to.be.equal('0xe5c2582e736f026d9304b0bb57c823d0e92a07fd0f0e410d29f76654bc6e4a9d');

    const onlineHash = await eventBridgeHashTest.calcEventsHash(eventHashes);
    expect(onlineHash).to.be.equal(offlineHash);
  });

  it('Should calc expected hash of 5 events', async function () {
    const { eventBridgeHashTest } = await loadFixture(deployFixture);

    const eventHashes = [
      '0xb5523a4f17bbe430b4dbe091b3598074d15565fe097d3f7dfbe96080075af6df',
      '0x1b8bf9a5eb4358e96e5d121df5306af056c4425e946e083112b6361671575de1',
      '0xb7812af23ddae316a22ac72c8ce0a34966e6a9a4836dc673a08eaa08db5a2dca',
      '0xfdf1d65f7c6703c8ff137405d6e4dfc9cb980ca4b22939ad1b092bf0e667e6ac',
      '0xb66bd9bcb7850e11a783e9e39751e2421486b709d45ec8b9858d6e241a5e2c95',
    ];

    const offlineHash = await calcEventsHash(eventHashes);
    expect(offlineHash).to.be.equal('0x0d361d67c9967a8c3faa1da111e2d064604e4d00ccf3e94aef29eee13646529c');

    const onlineHash = await eventBridgeHashTest.calcEventsHash(eventHashes);
    expect(onlineHash).to.be.equal(offlineHash);
  });
});
