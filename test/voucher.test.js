const hre = require('hardhat')
const { ethers } = hre
const { expect, time, constants } = require('@1inch/solidity-utils')
const { deployVoucher, deployToken } = require('./helpers/deploy')
const { signVoucher } = require('./helpers/signatureUtils')

describe('Voucher test', function () {
    const CHAIN_ID = 31337
    const tokenId = 1

    async function timestamp() {
        let blockNumber = await ethers.provider.getBlockNumber()
        let block = await ethers.provider.getBlock(blockNumber)

        return block.timestamp
    }

    let owner, signer, user_1, user_2

    before(async function () {
        [owner, signer, user_1, user_2] = await ethers.getSigners();
    })

    describe('Tests', function() {
        it("Method: safeMint", async function () {
            const token = await deployToken()
            const voucher = await deployVoucher(await token.getAddress())

            const base = {
                owner: user_1.address,
                tokenId: tokenId
            }

            const info = {
                value: 10,
                expirationDate: await timestamp() + 100
            }

            await voucher.safeMint(base, info)

            expect(await voucher.ownerOf(tokenId)).to.be.eq(user_1.address)
        })

        it("Method: burn", async function() {
            const token = await deployToken()
            const voucher = await deployVoucher(await token.getAddress())

            await token.transfer(await voucher.getAddress(), 10)

            const base = {
                owner: user_1.address,
                tokenId: tokenId
            }

            const info = {
                value: 10,
                expirationDate: await timestamp() + 100
            }

            await voucher.safeMint(base, info)

            await time.increase(120)

            await voucher.connect(user_1).burn(tokenId)

            expect(await token.balanceOf(user_1.address)).to.be.eq(10)
        })
    })
})
