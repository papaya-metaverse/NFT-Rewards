const { ethers } = require('hardhat');

async function deployStatus() {
    const name = "TEST_STATUS"
    const symbol = "STATUS"

    const args = [
        name,
        symbol
    ]

    const contract = await ethers.deployContract("Status", args)

    return contract
}

async function deployBadge() {
    const name = "TEST_BADGE"
    const symbol = "BADGE"

    const args = [
        name,
        symbol
    ]

    const contract = await ethers.deployContract("Badge", args)

    return contract
}

async function deployVoucher(tokenAddress) {
    const name = "TEST_VOUCHER"
    const symbol = "VOUCHER"

    const args = [
        name,
        symbol,
        tokenAddress
    ]

    const contract = await ethers.deployContract("Voucher", args)

    return contract
}

async function deployToken() {
    const name = "TEST"
    const symbol = "TST"
    const totalSupply = ethers.parseEther("2850000000000")
    const TOKEN_DECIMALS = 18

    const args = [
        name,
        symbol,
        totalSupply,
        TOKEN_DECIMALS
    ]

    const contract = await ethers.deployContract("TokenCustomDecimalsMock", args)

    return contract
}

async function deployMysteryBox(vrfWrapper, linkToken) {
    const args = [
        vrfWrapper,
        linkToken
    ]

    const contract = await ethers.deployContract("MysteryBox", args)

    return contract
}

module.exports = {
    deployStatus,
    deployBadge,
    deployMysteryBox,
    deployToken,
    deployVoucher
}
