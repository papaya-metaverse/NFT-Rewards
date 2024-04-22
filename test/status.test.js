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
            const status = await deployStatus()

            await status.safeMint(user_1.address, 0)

            expect(await status.ownerOf(0)).to.be.eq(user_1.address)
        })

        it("Method: upgradeNFT", async function() {
            const status = await deployStatus()

            await status.safeMint(user_1.address, 0)

            await status.upgradeNFT(0, 1)

            expect(await status.level(0)).to.be.eq(1)

        })
    })
})
