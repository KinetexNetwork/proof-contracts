import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';

import { encodeSignatureProof } from '../../../scripts/lib/contract/proof/signature/proofEncode';
import { SignatureProofEvent } from '../../../scripts/lib/contract/proof/signature/event';
import { EventProofVerifierDomainParams } from '../../../scripts/lib/contract/proof/signature/domainTyped';

import { OTHER_CHAIN_ID, TEST_CHAIN_ID } from '../../common/chainId';
import { expectRevert } from '../../common/revert';

describe('SignatureProofVerifierTest', function () {
  async function deployFixture() {
    const [ownerAccount, otherAccount, anotherAccount] = await ethers.getSigners();

    const SignatureProofVerifier = await ethers.getContractFactory('SignatureProofVerifier');
    const signatureProofVerifier = await SignatureProofVerifier.deploy(ownerAccount);

    const domain: EventProofVerifierDomainParams = {
      chainId: TEST_CHAIN_ID,
      verifyingContract: await signatureProofVerifier.getAddress(),
    };

    const event: SignatureProofEvent = {
      sig: '0xE5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5E5',
      arg: '0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF',
      chain: OTHER_CHAIN_ID,
      caller: otherAccount.address,
    };

    return {
      accounts: {
        owner: ownerAccount,
        other: otherAccount,
        another: anotherAccount,
      },
      signatureProofVerifier,
      domain,
      event,
    };
  }

  it('Should produce event proof with expected content', async function () {
    const { accounts, domain, event } = await loadFixture(deployFixture);

    const proof = await encodeSignatureProof({ domain, event, signer: accounts.owner });

    const offset = (word: number): number => 2 + 2 * 32 * word;
    const slice = (word: number, start = 0, end = 0): string => proof.slice(offset(word) + start, offset(word + 1) + start + end);

    expect(proof.length).to.be.equal(offset(6));
    expect(proof.slice(0, 2)).to.be.equal('0x');
    expect(slice(0)).to.be.equal('0000000000000000000000000000000000000000000000000000000000000007'); // Proof variant (7)
    expect(slice(1)).to.be.equal('0000000000000000000000000000000000000000000000000000000000000040'); // Signature offset (64)
    expect(slice(2)).to.be.equal('0000000000000000000000000000000000000000000000000000000000000041'); // Signature length (65)
    expect(slice(3)).to.be.not.equal('0000000000000000000000000000000000000000000000000000000000000000'); // Signature (0 - 31)
    expect(slice(4)).to.be.not.equal('0000000000000000000000000000000000000000000000000000000000000000'); // Signature (32 - 63)
    expect(slice(5, 2, -2)).to.be.equal('00000000000000000000000000000000000000000000000000000000000000'); // Signature pad (w/o 64)
  });

  it('Should verify valid event proof', async function () {
    const { accounts, signatureProofVerifier, domain, event } = await loadFixture(deployFixture);

    const proof = await encodeSignatureProof({ domain, event, signer: accounts.owner });

    await signatureProofVerifier.connect(accounts.other).verifyHashEventProof(
        event.sig,
        event.arg,
        event.chain,
        proof,
    );
  });

  it('Should not verify event proof when signed by non-owner account', async function () {
    const { accounts, signatureProofVerifier, domain, event } = await loadFixture(deployFixture);

    // Note: event signed by 'another' account, but contract is owned by 'owner'
    const proof = await encodeSignatureProof({ domain, event, signer: accounts.another });

    await expectRevert(
      signatureProofVerifier.connect(accounts.other).verifyHashEventProof(
          event.sig,
          event.arg,
          event.chain,
          proof,
      ),
      { customError: 'InvalidEventSignature()' },
    );
  });

  it('Should not verify event proof when signature param mismatch', async function () {
    const { accounts, signatureProofVerifier, domain, event } = await loadFixture(deployFixture);

    const proof = await encodeSignatureProof({ domain, event, signer: accounts.owner });

    // Note: last 'sig' bit flipped with '5' (0101) -> '4' (0100)
    expect(event.sig.slice(-1)).to.be.equal('5');
    const badSig = event.sig.slice(0, -1) + '4';

    await expectRevert(
      signatureProofVerifier.connect(accounts.other).verifyHashEventProof(
        badSig,
        event.arg,
        event.chain,
        proof,
      ),
      { customError: 'InvalidEventSignature()' },
    );
  });

  it('Should not verify event proof when argument param mismatch', async function () {
    const { accounts, signatureProofVerifier, domain, event } = await loadFixture(deployFixture);

    const proof = await encodeSignatureProof({ domain, event, signer: accounts.owner });

    // Note: last 'arg' bit flipped with 'F' (1111) -> 'E' (1110)
    expect(event.arg.slice(-1)).to.be.equal('F');
    const badArg = event.arg.slice(0, -1) + 'E';

    await expectRevert(
      signatureProofVerifier.connect(accounts.other).verifyHashEventProof(
        event.sig,
        badArg,
        event.chain,
        proof,
      ),
      { customError: 'InvalidEventSignature()' },
    );
  });

  it('Should not verify event proof when chain param mismatch', async function () {
    const { accounts, signatureProofVerifier, domain, event } = await loadFixture(deployFixture);

    const proof = await encodeSignatureProof({ domain, event, signer: accounts.owner });

    // Note: increment 'chain' by 1 to make it unexpected
    const badChain = event.chain + 1n;

    await expectRevert(
      signatureProofVerifier.connect(accounts.other).verifyHashEventProof(
        event.sig,
        event.arg,
        badChain,
        proof,
      ),
      { customError: 'InvalidEventSignature()' },
    );
  });

  it('Should not verify event proof when proof variant mismatch', async function () {
    const { accounts, signatureProofVerifier, domain, event } = await loadFixture(deployFixture);

    const proof = await encodeSignatureProof({ domain, event, signer: accounts.owner });

    // Note: replace proof 'variant' with '7' -> '8'
    expect(proof.slice(65, 66)).to.be.equal('7');
    const badProof = proof.slice(0, 65) + '8' + event.arg.slice(66);

    await expectRevert(
      signatureProofVerifier.connect(accounts.other).verifyHashEventProof(
        event.sig,
        event.arg,
        event.chain,
        badProof,
      ),
      { customError: 'InvalidEventSignature()' },
    );
  });

  it('Should not verify event proof when called from unauthorized account', async function () {
    const { accounts, signatureProofVerifier, domain, event } = await loadFixture(deployFixture);

    const proof = await encodeSignatureProof({ domain, event, signer: accounts.owner });

    // Note: event signature authorizes 'other' account, but called from 'owner'
    await expectRevert(
      signatureProofVerifier.verifyHashEventProof(
        event.sig,
        event.arg,
        event.chain,
        proof,
      ),
      { customError: 'InvalidEventSignature()' },
    );
  });

  it('Should not verify event proof when empty proof provided', async function () {
    const { accounts, signatureProofVerifier, event } = await loadFixture(deployFixture);

    await expectRevert(
      signatureProofVerifier.connect(accounts.other).verifyHashEventProof(
        event.sig,
        event.arg,
        event.chain,
        '0x',
      ),
      { customError: 'InvalidEventSignature()' },
    );
  });
});
