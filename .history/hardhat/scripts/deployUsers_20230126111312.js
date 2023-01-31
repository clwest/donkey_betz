const { ethers } = require('hardhat');

async function main() {

    const usersContract = await ethers.getContractFactory("Users");

    const deployedUsersContract = await usersContract.deploy("0xCF519B3E36d80F6de37D24A753d2662F1ffa5b7c", "0x8FcafEd5F31AD31031dE9106f2DEca0AAEFA3402");

    await deployedUsersContract.deployed()

    console.log("Users contract deployed to:", deployedUsersContract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1)
    })