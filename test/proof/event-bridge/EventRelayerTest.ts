import { ethers } from 'hardhat';
import { getCreateAddress, parseEther } from 'ethers';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';

import { encodeSends } from '../../../scripts/lib/contract/proof/event-bridge/sendEncode';

import { expectRevert } from '../../common/revert';
import { gasInfo } from '../../common/gas';
import { ANOTHER_CHAIN_ID, OTHER_CHAIN_ID } from '../../common/chainId';

const RELAY_TARGET_CHAIN = OTHER_CHAIN_ID;

describe('EventRelayerTest', function () {
  async function deployFixture() {
    const [account] = await ethers.getSigners();

    const EventBridgeSenderMock = await ethers.getContractFactory('EventBridgeSenderMock');
    const eventBridgeSenderMock = await EventBridgeSenderMock.deploy();

    const accountNonce = await account.getNonce();
    const relayerPredictedAddress = getCreateAddress({ from: account.address, nonce: accountNonce + 2 });

    const EventReceiverTest = await ethers.getContractFactory('EventReceiverTest');
    const eventReceiverTest = await EventReceiverTest.deploy(relayerPredictedAddress); // accountNonce + 0

    const TestWETH = await ethers.getContractFactory('TestWETH');
    const weth = await TestWETH.deploy(); // accountNonce + 1

    const EventBridgeRelayerFossil = await ethers.getContractFactory('EventBridgeRelayerFossil');
    const eventBridgeRelayer = await EventBridgeRelayerFossil.deploy( // accountNonce + 2
      [eventReceiverTest],
      1, // Threshold: 1 of 1
      [
        {
          chain: RELAY_TARGET_CHAIN,
          senders: [eventBridgeSenderMock],
        },
      ],
      weth,
    );

    return {
      eventBridgeSenderMock,
      eventReceiverTest,
      eventBridgeRelayer,
      weth,
    };
  }

  it('Should relay event hash', async function () {
    const {
      eventBridgeSenderMock,
      eventReceiverTest,
      eventBridgeRelayer,
      weth,
    } = await loadFixture(deployFixture);

    await weth.deposit({ value: parseEther('5') });
    await weth.approve(eventBridgeRelayer, parseEther('5'));

    await eventBridgeSenderMock.setExpectedValue(parseEther('5'));
    await eventBridgeSenderMock.setExpectedPayload('0x0112223333444445555556666666777777778888888889999999999AAAAAAAAA');

    {
      const sent = await eventBridgeSenderMock.payloadSent();
      expect(sent).to.be.equal(false);
    }

    const sends = await encodeSends([
      {
        sender: 0,
        value: parseEther('5'),
      },
    ]);

    await expectRevert(
      eventBridgeRelayer.relayEvent(
        '0x0112223333444445555556666666777777778888888889999999999AAAAAAAAA',
        RELAY_TARGET_CHAIN,
        sends,
      ),
      { customError: 'EventNotReceived()' },
    );

    await eventReceiverTest.receivePayload('0x0112223333444445555556666666777777778888888889999999999AAAAAAAAA');

    expect(ANOTHER_CHAIN_ID).to.be.not.equal(RELAY_TARGET_CHAIN);
    await expectRevert(
      eventBridgeRelayer.relayEvent(
        '0x0112223333444445555556666666777777778888888889999999999AAAAAAAAA',
        ANOTHER_CHAIN_ID, // Wrong relay target chain
        sends,
      ),
      { customError: 'NoSenderRoute()' },
    );

    await gasInfo(
      'relay event hash',
      await eventBridgeRelayer.relayEvent(
        '0x0112223333444445555556666666777777778888888889999999999AAAAAAAAA',
        RELAY_TARGET_CHAIN,
        sends,
      ),
    );

    {
      const sent = await eventBridgeSenderMock.payloadSent();
      expect(sent).to.be.equal(true);
    }
  });
});
