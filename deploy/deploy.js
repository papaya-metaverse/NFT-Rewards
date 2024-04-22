
const hre = require('hardhat');
const { getChainId } = hre;

module.exports = async ({ getNamedAccounts, deployments }) => {
    console.log("running deploy NFT script");
    console.log("network name: ", network.name);
    console.log("network id: ", await getChainId())

    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    {
        console.log("Deploy status");

        const name = "PAPAYA_Status"
        const symbol = "STATUS"

        const args = [
            name,
            symbol
        ]

        const status = await deploy('Status', {
            from: deployer,
            args
        })

        console.log("Status deployed to: ", status.address)

        await sleep(10000)

        if (await getChainId() !== '31337') {
            await hre.run(`verify:verify`, {
                address: status.address,
                constructorArguments: args
            })
        }
    }

    {
        console.log("Deploy badge")

        const name = "PAPAYA_Badge"
        const symbol = "BADGE"

        const args = [
            name,
            symbol
        ]

        const badge = await deploy('Badge', {
            from: deployer,
            args
        })

        console.log("Badge deployed to: ", badge.address)

        await sleep(10000)

        if (await getChainId() !== '31337') {
            await hre.run(`verify:verify`, {
                address: badge.address,
                constructorArguments: args
            })
        }
    }

    {
        console.log("Deploy Voucher")

        const name = "PAPAYA_Voucher"
        const symbol = "VOUCHER"
        const tokenAddress = "0x0000000000000000000000000000000000000000"

        const args = [
            name,
            symbol,
            tokenAddress
        ]

        const voucher = await deploy('Voucher', {
            from: deployer,
            args
        })

        console.log("Voucher deployed to: ", voucher.address)

        await sleep(10000)

        if (await getChainId() !== '31337') {
            await hre.run(`verify:verify`, {
                address: voucher.address,
                constructorArguments: args
            })
        }
    }

    {
        console.log("Deploy MysteryBox")

        const vrfWrapper = process.env.VRF_WRAPPER
        const linkToken = process.env.LINK_TOKEN

        const args = [
            vrfWrapper,
            linkToken
        ]

        const mysteryBox = await deploy('MysteryBox', {
            from: deployer,
            args
        })

        console.log("MysteryBox deployed to: ", mysteryBox.address)

        await sleep(10000)

        if (await getChainId() !== '31337') {
            await hre.run(`verify:verify`, {
                address: mysteryBox.address,
                constructorArguments: args
            })
        }
    }
};

module.exports.tags = ['NFT'];
