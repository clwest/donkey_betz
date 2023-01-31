const { ethers } = require('hardhat');

async function main() {

    const usersContract = await ethers.getContractFactory("Users");

    const deployedUsersContract = await usersContract.deploy("0xCF519B3E36d80F6de37D24A753d2662F1ffa5b7c", "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512");

    await deployedUsersContract.deployed()

    console.log("Users contract deployed to:", deployedUsersContract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1)
    })