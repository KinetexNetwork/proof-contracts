import { ethers } from 'hardhat';
import { getCreateAddress } from 'ethers';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';

import { calcEventsHash } from '../../../scripts/lib/contract/proof/event-bridge/eventsHash';

import { expectRevert } from '../../common/revert';
import { gasInfo } from '../../common/gas';

describe('EventBridgeAdapterTest', function () {
  async function deployFixture() {
    const [account] = await ethers.getSigners();

    const accountNonce = await account.getNonce();
    const adapterPredictedAddress = getCreateAddress({ from: account.address, nonce: accountNonce + 4 });

    const EventReceiverTest = await ethers.getContractFactory('EventReceiverTest');
    const eventReceiverTest0 = await EventReceiverTest.deploy(adapterPredictedAddress); // accountNonce + 0
    const eventReceiverTest1 = await EventReceiverTest.deploy(adapterPredictedAddress); // accountNonce + 1
    const eventReceiverTest2 = await EventReceiverTest.deploy(adapterPredictedAddress); // accountNonce + 2
    const eventReceiverTest3 = await EventReceiverTest.deploy(adapterPredictedAddress); // accountNonce + 3 // not writer

    const EventBridgeAdapterFossil = await ethers.getContractFactory('EventBridgeAdapterFossil');
    const eventBridgeAdapter = await EventBridgeAdapterFossil.deploy( // accountNonce + 4
      [
        eventReceiverTest0,
        eventReceiverTest1,
        eventReceiverTest2,
      ],
      2, // Threshold: 2 of 3
    );

    return {
      account,
      eventReceiverTest0,
      eventReceiverTest1,
      eventReceiverTest2,
      eventReceiverTest3,
      eventBridgeAdapter,
    };
  }

  it('Should recognize writers', async function () {
    const {
      account,
      eventReceiverTest0,
      eventReceiverTest1,
      eventReceiverTest2,
      eventReceiverTest3,
      eventBridgeAdapter,
    } = await loadFixture(deployFixture);

    {
      const canStore = await eventBridgeAdapter.canStore(eventReceiverTest3);
      expect(canStore).to.be.equal(false);
    }
    {
      const canStore = await eventBridgeAdapter.canStore(account);
      expect(canStore).to.be.equal(false);
    }

    {
      const canStore = await eventBridgeAdapter.canStore(eventReceiverTest0);
      expect(canStore).to.be.equal(true);
    }
    {
      const canStore = await eventBridgeAdapter.canStore(eventReceiverTest1);
      expect(canStore).to.be.equal(true);
    }
    {
      const canStore = await eventBridgeAdapter.canStore(eventReceiverTest2);
      expect(canStore).to.be.equal(true);
    }
  });

  it('Should assign writer store flags & indexes', async function() {
    const {
      account,
      eventReceiverTest0,
      eventReceiverTest1,
      eventReceiverTest2,
      eventReceiverTest3,
      eventBridgeAdapter,
    } = await loadFixture(deployFixture);

    {
      const cans = await eventBridgeAdapter.canStore(eventReceiverTest3);
      expect(cans).to.be.equal(false);
      const mask = await eventBridgeAdapter.writerIndex(eventReceiverTest3);
      expect(mask).to.be.equal(0n);
    }
    {
      const cans = await eventBridgeAdapter.canStore(account);
      expect(cans).to.be.equal(false);
      const mask = await eventBridgeAdapter.writerIndex(account);
      expect(mask).to.be.equal(0n);
    }

    {
      const cans = await eventBridgeAdapter.canStore(eventReceiverTest0);
      expect(cans).to.be.equal(true);
      const mask = await eventBridgeAdapter.writerIndex(eventReceiverTest0);
      expect(mask).to.be.equal(0n);
    }
    {
      const cans = await eventBridgeAdapter.canStore(eventReceiverTest1);
      expect(cans).to.be.equal(true);
      const mask = await eventBridgeAdapter.writerIndex(eventReceiverTest1);
      expect(mask).to.be.equal(1n);
    }
    {
      const cans = await eventBridgeAdapter.canStore(eventReceiverTest2);
      expect(cans).to.be.equal(true);
      const mask = await eventBridgeAdapter.writerIndex(eventReceiverTest2);
      expect(mask).to.be.equal(2n);
    }
  });

  it('Should save authorized write', async function () {
    const {
      eventReceiverTest0,
      eventReceiverTest1,
      eventReceiverTest2,
      eventBridgeAdapter,
    } = await loadFixture(deployFixture);

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
      const byTest2 = await eventBridgeAdapter.isHashStoredBy('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e', eventReceiverTest2);
      expect(byTest2).to.be.equal(false);
      const byTest0 = await eventBridgeAdapter.isHashStoredBy('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e', eventReceiverTest0);
      expect(byTest0).to.be.equal(false);
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
      const byTest2 = await eventBridgeAdapter.isHashStoredBy('0x7777777777777777777777777777777777777777777777777777777777777777', eventReceiverTest2);
      expect(byTest2).to.be.equal(false);
      const byTest0 = await eventBridgeAdapter.isHashStoredBy('0x7777777777777777777777777777777777777777777777777777777777777777', eventReceiverTest0);
      expect(byTest0).to.be.equal(false);
    }

    await gasInfo(
      'write event (first, type #0)',
      await eventReceiverTest2.receivePayload('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e'),
    );

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000004'); // 0b...0100 (4)
      const byTest2 = await eventBridgeAdapter.isHashStoredBy('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e', eventReceiverTest2);
      expect(byTest2).to.be.equal(true);
      const byTest0 = await eventBridgeAdapter.isHashStoredBy('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e', eventReceiverTest0);
      expect(byTest0).to.be.equal(false);
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
      const byTest2 = await eventBridgeAdapter.isHashStoredBy('0x7777777777777777777777777777777777777777777777777777777777777777', eventReceiverTest2);
      expect(byTest2).to.be.equal(false);
      const byTest0 = await eventBridgeAdapter.isHashStoredBy('0x7777777777777777777777777777777777777777777777777777777777777777', eventReceiverTest0);
      expect(byTest0).to.be.equal(false);
    }

    await gasInfo(
      'write event (second, type #0)',
      await eventReceiverTest0.receivePayload('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e'),
    );

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000005'); // 0b...0101 (5)
      const byTest2 = await eventBridgeAdapter.isHashStoredBy('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e', eventReceiverTest2);
      expect(byTest2).to.be.equal(true);
      const byTest0 = await eventBridgeAdapter.isHashStoredBy('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e', eventReceiverTest0);
      expect(byTest0).to.be.equal(true);
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
      const byTest2 = await eventBridgeAdapter.isHashStoredBy('0x7777777777777777777777777777777777777777777777777777777777777777', eventReceiverTest2);
      expect(byTest2).to.be.equal(false);
      const byTest0 = await eventBridgeAdapter.isHashStoredBy('0x7777777777777777777777777777777777777777777777777777777777777777', eventReceiverTest0);
      expect(byTest0).to.be.equal(false);
    }

    await gasInfo(
      'write event (duplicate of first, type #0)',
      await eventReceiverTest2.receivePayload('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e'),
    );

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000005'); // 0b...0101 (5)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }

    await gasInfo(
      'write event (first, type #1)',
      await eventReceiverTest0.receivePayload('0x7777777777777777777777777777777777777777777777777777777777777777'),
    );

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000005'); // 0b...0101 (5)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000001'); // 0b...0001 (1)
    }

    await gasInfo(
      'write event (second, type #1)',
      await eventReceiverTest1.receivePayload('0x7777777777777777777777777777777777777777777777777777777777777777'),
    );

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000005'); // 0b...0101 (5)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000003'); // 0b...0011 (3)
    }
  });

  it('Should not save unauthorized write', async function () {
    const {
      account,
      eventReceiverTest3,
      eventBridgeAdapter,
    } = await loadFixture(deployFixture);

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }

    await expectRevert(
      eventBridgeAdapter.connect(account).storeHash('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e'),
      { customError: 'UnauthorizedStore(.*)' },
    );

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }

    await expectRevert(
      eventReceiverTest3.receivePayload('0x7777777777777777777777777777777777777777777777777777777777777777'),
      { customError: 'UnauthorizedStore(.*)' },
    );

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
  });

  it('Should save restored array of storeCount', async function () {
    const {
      eventReceiverTest1,
      eventReceiverTest2,
      eventBridgeAdapter,
    } = await loadFixture(deployFixture);

    {
      const eventHashes = [
        '0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e',
        '0x7777777777777777777777777777777777777777777777777777777777777777',
        '0x1111111111111111111111111111111111111111111111111111111111111111',
      ];
      const eventsHash = await calcEventsHash(eventHashes);
      expect(eventsHash).to.be.equal('0x2075099a14ad0e1e4893121e5eb5d9ebea2324b98b2f244e4a32dd13f877d33e');

      {
        const received = await eventReceiverTest2.eventHashesReceived(eventsHash);
        expect(received).to.be.equal(false);
      }

      await expectRevert(
        eventReceiverTest2.restoreEventHashes(eventHashes),
        { customError: 'RestoreHashNotReceived()' },
      );

      await gasInfo(
        'receive event payload (restorable hash, first write)',
        await eventReceiverTest2.receivePayload(eventsHash),
      );

      {
        const received = await eventReceiverTest2.eventHashesReceived(eventsHash);
        expect(received).to.be.equal(true);
      }

      await gasInfo(
        'restore event payloads from hash (3 elements - 3 first storeCount)',
        await eventReceiverTest2.restoreEventHashes(eventHashes),
      );
    }

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000004'); // 0b...0100 (4)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000004'); // 0b...0100 (4)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x1111111111111111111111111111111111111111111111111111111111111111');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000004'); // 0b...0100 (4)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x0000000000000000000000000000000000000000000000000000000000000000');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }

    {
      const eventHashes = [
        '0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e',
        '0x7777777777777777777777777777777777777777777777777777777777777777',
      ];
      const eventsHash = await calcEventsHash(eventHashes);
      expect(eventsHash).to.be.equal('0xb25bedcd619610d0d8638f18ece506a2b6a5cb2654f0902d691d80dee5f573df');

      {
        const received = await eventReceiverTest1.eventHashesReceived(eventsHash);
        expect(received).to.be.equal(false);
      }

      await expectRevert(
        eventReceiverTest1.restoreEventHashes(eventHashes),
        { customError: 'RestoreHashNotReceived()' },
      );

      await gasInfo(
        'receive event payload (restorable hash, first write)',
        await eventReceiverTest1.receivePayload(eventsHash),
      );

      {
        const received = await eventReceiverTest1.eventHashesReceived(eventsHash);
        expect(received).to.be.equal(true);
      }

      await gasInfo(
        'restore event payloads from hash (2 elements - 2 second storeCount)',
        await eventReceiverTest1.restoreEventHashes(eventHashes),
      );
    }

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000006'); // 0b...0110 (6)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000006'); // 0b...0110 (6)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x1111111111111111111111111111111111111111111111111111111111111111');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000004'); // 0b...0100 (4)
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x0000000000000000000000000000000000000000000000000000000000000000');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
  });

  it('Should not save non-restorable array of storeCount', async function () {
    const {
      eventReceiverTest2,
      eventBridgeAdapter,
    } = await loadFixture(deployFixture);

    {
      const eventHashes = [
        '0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e',
        '0x7777777777777777777777777777777777777777777777777777777777777777',
        '0x1111111111111111111111111111111111111111111111111111111111111111',
      ];
      const eventsHash = await calcEventsHash(eventHashes);
      expect(eventsHash).to.be.equal('0x2075099a14ad0e1e4893121e5eb5d9ebea2324b98b2f244e4a32dd13f877d33e');

      const corruptedEventsHash = '0xb53c76670265520c9eb169f1c0f3c902f57d572ae6fd005e49aa06de362a5bbd'; // Last bit flipped
      expect(corruptedEventsHash).to.be.not.equal(eventsHash);

      {
        const received = await eventReceiverTest2.eventHashesReceived(eventsHash);
        expect(received).to.be.equal(false);
      }
      {
        const received = await eventReceiverTest2.eventHashesReceived(corruptedEventsHash);
        expect(received).to.be.equal(false);
      }

      await expectRevert(
        eventReceiverTest2.restoreEventHashes(eventHashes),
        { customError: 'RestoreHashNotReceived()' },
      );

      await eventReceiverTest2.receivePayload(corruptedEventsHash);

      {
        const received = await eventReceiverTest2.eventHashesReceived(eventsHash);
        expect(received).to.be.equal(false);
      }
      {
        const received = await eventReceiverTest2.eventHashesReceived(corruptedEventsHash);
        expect(received).to.be.equal(true);
      }

      await expectRevert(
        eventReceiverTest2.restoreEventHashes(eventHashes),
        { customError: 'RestoreHashNotReceived()' },
      );
    }

    {
      const report = await eventBridgeAdapter.hashReport('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x1111111111111111111111111111111111111111111111111111111111111111');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
    {
      const report = await eventBridgeAdapter.hashReport('0x0000000000000000000000000000000000000000000000000000000000000000');
      expect(report).to.be.equal('0x0000000000000000000000000000000000000000000000000000000000000000');
    }
  });

  it('Should consider event received when threshold reached', async function () {
    const {
      eventReceiverTest0,
      eventReceiverTest1,
      eventReceiverTest2,
      eventReceiverTest3,
      eventBridgeAdapter,
    } = await loadFixture(deployFixture);

    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(storeCount).to.be.equal(0);
      const received = await eventBridgeAdapter.eventReceived('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(received).to.be.equal(false);
    }
    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(storeCount).to.be.equal(0);
      const received = await eventBridgeAdapter.eventReceived('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(received).to.be.equal(false);
    }

    await eventReceiverTest2.receivePayload('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');

    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(storeCount).to.be.equal(1);
      const received = await eventBridgeAdapter.eventReceived('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(received).to.be.equal(false);
    }
    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(storeCount).to.be.equal(0);
      const received = await eventBridgeAdapter.eventReceived('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(received).to.be.equal(false);
    }

    await eventReceiverTest2.receivePayload('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');

    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(storeCount).to.be.equal(1);
      const received = await eventBridgeAdapter.eventReceived('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(received).to.be.equal(false);
    }
    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(storeCount).to.be.equal(0);
      const received = await eventBridgeAdapter.eventReceived('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(received).to.be.equal(false);
    }

    await eventReceiverTest2.receivePayload('0x7777777777777777777777777777777777777777777777777777777777777777');

    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(storeCount).to.be.equal(1);
      const received = await eventBridgeAdapter.eventReceived('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(received).to.be.equal(false);
    }
    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(storeCount).to.be.equal(1);
      const received = await eventBridgeAdapter.eventReceived('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(received).to.be.equal(false);
    }

    await expectRevert(
      eventReceiverTest3.receivePayload('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e'),
      { customError: 'UnauthorizedStore(.*)' },
    );
    await expectRevert(
      eventReceiverTest3.receivePayload('0x7777777777777777777777777777777777777777777777777777777777777777'),
      { customError: 'UnauthorizedStore(.*)' },
    );

    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(storeCount).to.be.equal(1);
      const received = await eventBridgeAdapter.eventReceived('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(received).to.be.equal(false);
    }
    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(storeCount).to.be.equal(1);
      const received = await eventBridgeAdapter.eventReceived('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(received).to.be.equal(false);
    }

    await eventReceiverTest1.receivePayload('0x7777777777777777777777777777777777777777777777777777777777777777');

    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(storeCount).to.be.equal(1);
      const received = await eventBridgeAdapter.eventReceived('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(received).to.be.equal(false);
    }
    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(storeCount).to.be.equal(2);
      const received = await eventBridgeAdapter.eventReceived('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(received).to.be.equal(true);
    }

    await eventReceiverTest0.receivePayload('0x7777777777777777777777777777777777777777777777777777777777777777');

    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(storeCount).to.be.equal(1);
      const received = await eventBridgeAdapter.eventReceived('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(received).to.be.equal(false);
    }
    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(storeCount).to.be.equal(3);
      const received = await eventBridgeAdapter.eventReceived('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(received).to.be.equal(true);
    }

    await eventReceiverTest0.receivePayload('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');

    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(storeCount).to.be.equal(2);
      const received = await eventBridgeAdapter.eventReceived('0x0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e');
      expect(received).to.be.equal(true);
    }
    {
      const storeCount = await eventBridgeAdapter.hashStoreCount('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(storeCount).to.be.equal(3);
      const received = await eventBridgeAdapter.eventReceived('0x7777777777777777777777777777777777777777777777777777777777777777');
      expect(received).to.be.equal(true);
    }
  });
});
