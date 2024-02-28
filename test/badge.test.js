const hre = require('hardhat')
const { ethers } = hre
const { expect, time, constants } = require('@1inch/solidity-utils')
const { deployBadge } = require('./helpers/deploy') 

describe('Status test', function () {
    let owner, signer, user_1, user_2

    before(async function () {
        [owner, signer, user_1, user_2] = await ethers.getSigners();
    })

    it("Method: safeMint", async function () {
        const badge = await deployBadge()

        await badge.safeMint(user_1.address, 0)

        expect(await badge.ownerOf(0)).to.be.eq(user_1.address)
    })

    it("Method: transfer", async function () {
        const badge = await deployBadge()

        await badge.safeMint(user_1.address, 0)

        await badge.unpause()

        await badge.connect(user_1).transferFrom(user_1.address, owner.address, 0)

        expect(await badge.ownerOf(0)).to.be.eq(owner.address)
    })
})
