const { ethers } = hre

const SIGNING_DOMAIN_NAME = 'NFTSigVerifier';
const SIGNING_DOMAIN_VERSION = '1';

StatusMint = {
    StatusMintSig: [
        {name: 'sig', type: 'Sig'},
        {name: 'base', type: 'NftBase'}
    ],
    NftBase: [
        {name: 'owner', type: 'address'},
        {name: 'tokenId', type: 'uint256'}
    ],
    Sig: [
        {name: 'signer', type: 'address'},
        {name: 'nonce', type: 'uint256'},
        {name: 'executionFee', type: 'uint256'}
    ]
}

StatusUpgrade = {
    StatusUpgradeSig: [
        {name: 'sig', type: 'Sig'},
        {name: 'tokenId', type: 'uint256'},
        {name: 'level', type: 'uint256'}
    ],
    Sig: [
        {name: 'signer', type: 'address'},
        {name: 'nonce', type: 'uint256'},
        {name: 'executionFee', type: 'uint256'}
    ]
}

Voucher = {
    VoucherSig: [
        {name: 'sig', type: 'Sig'},
        {name: 'base', type: 'NftBase'},
        {name: 'info', type: 'VoucherInfo'}
    ],
    NftBase: [
        {name: 'owner', type: 'address'},
        {name: 'tokenId', type: 'uint256'}
    ],
    Sig: [
        {name: 'signer', type: 'address'},
        {name: 'nonce', type: 'uint256'},
        {name: 'executionFee', type: 'uint256'}
    ],
    VoucherInfo: [
        {name: 'value', type: 'uint216'},
        {name: 'expirationDate', type: 'uint40'}
    ]
}

MysteryBox = {
    MysteryBoxSig: [
        {name: 'sig', type: 'Sig'},
        {name: 'user', type: 'address'}
    ],
    Sig: [
        {name: 'signer', type: 'address'},
        {name: 'nonce', type: 'uint256'},
        {name: 'executionFee', type: 'uint256'}
    ],
}

function buildData (chainId_, verifyingContract_, types, data){
    const domain = {
      name: SIGNING_DOMAIN_NAME,
      version: SIGNING_DOMAIN_VERSION,
      chainId: chainId_,
      verifyingContract: verifyingContract_
    }
    
    return {
      domain: domain,
      types: types,
      value: data
    }
}

async function signMint (chainId, target, statusMintData, wallet) {
    const data = buildData(chainId, target, StatusMint, statusMintData)
    return await wallet.signTypedData(data.domain, data.types, data.value)
}

async function signUpgrade (chainId, target, statusUpgradeData, wallet) {
    const data = buildData(chainId, target, StatusUpgrade, statusUpgradeData)
    return await wallet.signTypedData(data.domain, data.types, data.value)
}

async function signVoucher (chainId, target, voucherData, wallet) {
    const data = buildData(chainId, target, Voucher, voucherData)
    return await wallet.signTypedData(data.domain, data.types, data.value)
}

async function signMysteryBox (chainId, target, mysteryBoxData, wallet) {
    const data = buildData(chainId, target, MysteryBox, mysteryBoxData)
    return await wallet.signTypedData(data.domain, data.types, data.value)
}

module.exports = {
    signMint,
    signUpgrade,
    signVoucher,
    signMysteryBox
}