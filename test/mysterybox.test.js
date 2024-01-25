const hre = require('hardhat')
const { ethers } = hre
const { expect, time, constants } = require('@1inch/solidity-utils')
const { deployMysteryBox } = require('./helpers/deploy') 
const { signMysteryBox } = require('./helpers/signatureUtils')

describe('Status test', function () {
    const CHAIN_ID = 31337    

    //RewardTypes
    const VCREDITS = 0
    const EXPERIENCE = 1 
    const VOUCHER = 2

    let owner, signer, user_1, user_2

    before(async function () {
        [owner, signer, user_1, user_2] = await ethers.getSigners();
    })

    describe('Tests', function () {
        it("Method: updatePrizeInfo", async function() {
            const mysteryBox = await deployMysteryBox(constants.ZERO_ADDRESS, constants.ZERO_ADDRESS, signer.address)

            let XP_Probability = 70

            let PrizeInfoXP_0 = {
                upperBound: 80,
                cost: 50
            }

            let PrizeInfoXP_1 = {
                upperBound: 100,
                cost: 100
            }

            let XP_InfoArr = [PrizeInfoXP_0, PrizeInfoXP_1]

            await mysteryBox.updatePrizeInfo(EXPERIENCE, XP_Probability, XP_InfoArr)          
        })
    })
})
