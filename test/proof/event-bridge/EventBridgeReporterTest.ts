import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { parseEther } from 'ethers';

import { SenderFossilConfigStruct } from '../../../typechain-types/contracts/proof/event-bridge/reporter/EventBridgeReporterFossil';

import { encodeSends } from '../../../scripts/lib/contract/proof/event-bridge/sendEncode';

import { calcEventHash } from '../../../scripts/lib/contract/utils/eventHash';

import { gasInfo } from '../../common/gas';
import { expectRevert } from '../../common/revert';
import { OTHER_CHAIN_ID } from '../../common/chainId';

const REPORT_TARGET_CHAIN = OTHER_CHAIN_ID;
const EVENT_SIGNATURES = [
  '0xE5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5',
  '0xF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7',
  '0x1111111122222222333333334444444411111111222222223333333344444444',
  '0x6666666666666666666666666666666666666666666666666666666666666666',
  '0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF',
] as const;
const EVENT_ARG = '0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF';

describe('EventBridgeReporterTest', function () {
  async function deployFixture() {
    const [account] = await ethers.getSigners();

    const TestWETH = await ethers.getContractFactory('TestWETH');
    const weth = await TestWETH.deploy();

    const EventBridgeSenderMock = await ethers.getContractFactory('EventBridgeSenderMock');
    const eventBridgeSenderMock0 = await EventBridgeSenderMock.deploy();
    const eventBridgeSenderMock1 = await EventBridgeSenderMock.deploy();

    const BitAuthHashStorage = await ethers.getContractFactory('BitAuthHashStorage')
    const eventHashStorage = await BitAuthHashStorage.deploy([account]);

    const senderConfigs: SenderFossilConfigStruct[] = [
      {
        chain: REPORT_TARGET_CHAIN,
        senders: [
          eventBridgeSenderMock0,
          eventBridgeSenderMock1,
        ],
      }
    ];

    const EventBridgeReporterFossil = await ethers.getContractFactory('EventBridgeReporterFossil');
    const eventBridgeReporter = await EventBridgeReporterFossil.deploy(
      eventHashStorage,
      weth,
      senderConfigs,
    );

    return {
      account,
      weth,
      eventHashStorage,
      eventBridgeSenderMock0,
      eventBridgeSenderMock1,
      eventBridgeReporter,
    };
  }

  it('Should report event', async function () {
    const {
      account,
      weth,
      eventHashStorage,
      eventBridgeReporter,
      eventBridgeSenderMock0,
      eventBridgeSenderMock1,
    } = await loadFixture(deployFixture);

    {
      const wethBalanceBefore = await weth.balanceOf(account);
      await weth.deposit({ value: parseEther('1') });
      const wethBalanceAfter = await weth.balanceOf(account);
      expect(wethBalanceAfter).to.be.equal(wethBalanceBefore + parseEther('1'));
    }

    {
      const wethAllowanceBefore = await weth.allowance(account, eventBridgeReporter);
      await weth.approve(eventBridgeReporter, parseEther('1'));
      const wethAllowanceAfter = await weth.allowance(account, eventBridgeReporter);
      expect(wethAllowanceAfter).to.be.equal(wethAllowanceBefore + parseEther('1'));
    }

    const receiveEventHash = await calcEventHash(EVENT_SIGNATURES[0], EVENT_ARG);
    const sends = await encodeSends([
      {
        sender: 0,
        value: parseEther('1'),
      },
    ]);

    {
      await expectRevert(
        eventBridgeReporter.reportEvent(receiveEventHash, REPORT_TARGET_CHAIN, sends),
        { customError: 'EventHashNotStored()' },
      );
    }

    {
      await eventHashStorage.storeHash(receiveEventHash);

      await eventBridgeSenderMock0.setExpectedPayload('0xb5523a4f17bbe430b4dbe091b3598074d15565fe097d3f7dfbe96080075af6df');
      await eventBridgeSenderMock0.setExpectedValue(parseEther('1'));
    }

    {
      const accountWethBalanceBefore = await weth.balanceOf(account);

      await gasInfo(
        'report event (1 send)',
        await eventBridgeReporter.reportEvent(receiveEventHash, REPORT_TARGET_CHAIN, sends),
      );

      const payloadSent0 = await eventBridgeSenderMock0.payloadSent();
      expect(payloadSent0).to.be.equal(true);
      const payloadSent1 = await eventBridgeSenderMock1.payloadSent();
      expect(payloadSent1).to.be.equal(false);

      const accountWethBalanceAfter = await weth.balanceOf(account);
      expect(accountWethBalanceAfter).to.be.equal(accountWethBalanceBefore - parseEther('1'));
    }
  });

  it('Should report event with 2 sends', async function () {
    const {
      account,
      weth,
      eventHashStorage,
      eventBridgeReporter,
      eventBridgeSenderMock0,
      eventBridgeSenderMock1,
    } = await loadFixture(deployFixture);

    {
      const wethBalanceBefore = await weth.balanceOf(account);
      await weth.deposit({ value: parseEther('2') });
      const wethBalanceAfter = await weth.balanceOf(account);
      expect(wethBalanceAfter).to.be.equal(wethBalanceBefore + parseEther('2'));
    }

    {
      const wethAllowanceBefore = await weth.allowance(account, eventBridgeReporter);
      await weth.approve(eventBridgeReporter, parseEther('2'));
      const wethAllowanceAfter = await weth.allowance(account, eventBridgeReporter);
      expect(wethAllowanceAfter).to.be.equal(wethAllowanceBefore + parseEther('2'));
    }

    const receiveEventHash = await calcEventHash(EVENT_SIGNATURES[0], EVENT_ARG);
    const sends = await encodeSends([
      {
        sender: 1,
        value: parseEther('0.69'),
      },
      {
        sender: 0,
        value: parseEther('1.31'),
      },
    ]);

    {
      await expectRevert(
        eventBridgeReporter.reportEvent(receiveEventHash, REPORT_TARGET_CHAIN, sends),
        { customError: 'EventHashNotStored()' },
      );
    }

    await eventHashStorage.storeHash(receiveEventHash);

    {
      await eventBridgeSenderMock0.setExpectedPayload('0xb5523a4f17bbe430b4dbe091b3598074d15565fe097d3f7dfbe96080075af6df');
      await eventBridgeSenderMock0.setExpectedValue(parseEther('1.31'));

      await eventBridgeSenderMock1.setExpectedPayload('0xb5523a4f17bbe430b4dbe091b3598074d15565fe097d3f7dfbe96080075af6df');
      await eventBridgeSenderMock1.setExpectedValue(parseEther('0.69'));
    }

    {
      const accountWethBalanceBefore = await weth.balanceOf(account);

      await gasInfo(
        'report event (2 sends)',
        await eventBridgeReporter.reportEvent(receiveEventHash, REPORT_TARGET_CHAIN, sends),
      );

      const payloadSent0 = await eventBridgeSenderMock0.payloadSent();
      expect(payloadSent0).to.be.equal(true);
      const payloadSent1 = await eventBridgeSenderMock1.payloadSent();
      expect(payloadSent1).to.be.equal(true);

      const accountWethBalanceAfter = await weth.balanceOf(account);
      expect(accountWethBalanceAfter).to.be.equal(accountWethBalanceBefore - parseEther('2'));
    }
  });

  it('Should report 2 events', async function () {
    const {
      weth,
      eventHashStorage,
      eventBridgeReporter,
      eventBridgeSenderMock0,
      eventBridgeSenderMock1,
    } = await loadFixture(deployFixture);

    await weth.deposit({ value: parseEther('0.25') });
    await weth.approve(eventBridgeReporter, parseEther('0.25'));

    const eventHashes = [
      await calcEventHash(EVENT_SIGNATURES[0], EVENT_ARG),
      await calcEventHash(EVENT_SIGNATURES[1], EVENT_ARG),
    ];
    const sends = await encodeSends([
      {
        sender: 1,
        value: parseEther('0.25'),
      },
    ])

    await expectRevert(
      eventBridgeReporter.reportEvents(eventHashes, REPORT_TARGET_CHAIN, sends),
      { customError: 'EventHashNotStored()' },
    );

    await eventHashStorage.storeHash(eventHashes[1]);

    await expectRevert(
      eventBridgeReporter.reportEvents(eventHashes, REPORT_TARGET_CHAIN, sends),
      { customError: 'EventHashNotStored()' },
    );

    await eventHashStorage.storeHash(eventHashes[0]);

    {
      await eventBridgeSenderMock1.setExpectedPayload('0xe5c2582e736f026d9304b0bb57c823d0e92a07fd0f0e410d29f76654bc6e4a9d');
      await eventBridgeSenderMock1.setExpectedValue(parseEther('0.25'));
    }

    {
      await gasInfo(
        'report multiple events (2 events, 1 send)',
        await eventBridgeReporter.reportEvents(eventHashes, REPORT_TARGET_CHAIN, sends),
      );

      const payloadSent0 = await eventBridgeSenderMock0.payloadSent();
      expect(payloadSent0).to.be.equal(false);
      const payloadSent1 = await eventBridgeSenderMock1.payloadSent();
      expect(payloadSent1).to.be.equal(true);
    }
  });

  it('Should report 5 events with 2 sends', async function () {
    const {
      weth,
      eventHashStorage,
      eventBridgeReporter,
      eventBridgeSenderMock0,
      eventBridgeSenderMock1,
    } = await loadFixture(deployFixture);

    await weth.deposit({ value: parseEther('1.23') });
    await weth.approve(eventBridgeReporter, parseEther('1.23'));

    const eventHashes = [
      await calcEventHash(EVENT_SIGNATURES[0], EVENT_ARG),
      await calcEventHash(EVENT_SIGNATURES[1], EVENT_ARG),
      await calcEventHash(EVENT_SIGNATURES[2], EVENT_ARG),
      await calcEventHash(EVENT_SIGNATURES[3], EVENT_ARG),
      await calcEventHash(EVENT_SIGNATURES[4], EVENT_ARG),
    ];
    const sends = await encodeSends([
      {
        sender: 0,
        value: parseEther('0.99'),
      },
      {
        sender: 1,
        value: parseEther('0.24'),
      },
    ])

    await expectRevert(
      eventBridgeReporter.reportEvents(eventHashes, REPORT_TARGET_CHAIN, sends),
      { customError: 'EventHashNotStored()' },
    );

    await eventHashStorage.storeHash(eventHashes[0]);
    await eventHashStorage.storeHash(eventHashes[1]);
    await eventHashStorage.storeHash(eventHashes[3]);

    await expectRevert(
      eventBridgeReporter.reportEvents(eventHashes, REPORT_TARGET_CHAIN, sends),
      { customError: 'EventHashNotStored()' },
    );

    await eventHashStorage.storeHash(eventHashes[4]);

    await expectRevert(
      eventBridgeReporter.reportEvents(eventHashes, REPORT_TARGET_CHAIN, sends),
      { customError: 'EventHashNotStored()' },
    );

    await eventHashStorage.storeHash(eventHashes[2]);

    {
      await eventBridgeSenderMock0.setExpectedPayload('0x0d361d67c9967a8c3faa1da111e2d064604e4d00ccf3e94aef29eee13646529c');
      await eventBridgeSenderMock0.setExpectedValue(parseEther('0.99'));

      await eventBridgeSenderMock1.setExpectedPayload('0x0d361d67c9967a8c3faa1da111e2d064604e4d00ccf3e94aef29eee13646529c');
      await eventBridgeSenderMock1.setExpectedValue(parseEther('0.24'));
    }

    {
      await gasInfo(
        'report multiple events (5 events, 2 sends)',
        await eventBridgeReporter.reportEvents(eventHashes, REPORT_TARGET_CHAIN, sends),
      );

      const payloadSent0 = await eventBridgeSenderMock0.payloadSent();
      expect(payloadSent0).to.be.equal(true);
      const payloadSent1 = await eventBridgeSenderMock0.payloadSent();
      expect(payloadSent1).to.be.equal(true);
    }
  });
});
