const hre = require('hardhat')
const { ethers } = hre
const { expect, time, constants } = require('@1inch/solidity-utils')
const { deployStatus } = require('./helpers/deploy') 
const { signMint, signUpgrade } = require('./helpers/signatureUtils')

describe('Status test', function () {
    const CHAIN_ID = 31337    

    let owner, signer, user_1, user_2

    before(async function () {
        [owner, signer, user_1, user_2] = await ethers.getSigners();
    })

    describe('Tests', function () {
        it("Method: safeMint", async function() {
            const status = await deployStatus(signer.address)

            await status.safeMint(user_1.address, 0)

            expect(await status.ownerOf(0)).to.be.eq(user_1.address)
        })        
        it("Method: mintBySig", async function() {
            const status = await deployStatus(signer.address)

            const nonce = await status.nonces(await user_1.address)

            const mintData = {
                sig: {
                    signer: signer.address,
                    nonce: nonce,
                    executionFee: 0
                },
                base: {
                    owner: user_1.address,
                    tokenId: 0
                }
            }

            const signature = await signMint(CHAIN_ID, status.address, mintData, signer)

            await status.connect(user_1).mintBySig(mintData, signature)

            expect(await status.ownerOf(0)).to.be.eq(user_1.address)
        })

        it("Method: upgradeNFT", async function() {
            const status = await deployStatus(signer.address)

            await status.safeMint(user_1.address, 0)

            await status.upgradeNFT(0, 1)

            expect(await status.level(0)).to.be.eq(1)

        })

        it("Method: upgradeBySig", async function() {
            const status = await deployStatus(signer.address)

            await status.safeMint(user_1.address, 0)

            const nonce = await status.nonces(await user_1.address)

            const upgradeData = {
                sig: {
                    signer: signer.address,
                    nonce: nonce,
                    executionFee: 0
                },
                tokenId: 0,
                level: 1
            }

            const signature = await signUpgrade(CHAIN_ID, status.address, upgradeData, signer)

            await status.connect(user_1).upgradeBySig(upgradeData, signature)

            expect(await status.level(0)).to.be.eq(1)
        })
    })
})
