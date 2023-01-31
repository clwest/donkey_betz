const { ethers } = require('hardhat');

async function main() {

    const usersContract = await ethers.getContractFactory("Users");

    const deployedUsersContract = await usersContract.deploy("0x4e60Dc60D914051CF20fE16F8d3a483e5351a286", "0x4e5f8826a5155dbFCA8Ac920411Ffb75C7297F7D");

    await deployedUsersContract.deployed()

    console.log("Users contract deployed to:", deployedUsersContract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1)
    })