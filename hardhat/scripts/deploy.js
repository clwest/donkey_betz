const { ethers } = require('hardhat');

async function main() {

  //
  const signer = await ethers.getSigner();

  // Deploy the Roles Contract
  const rolesFactory = await ethers.getContractFactory("Roles", signer);
  const deployedRoles = await rolesFactory.deploy();

  console.log(`Roles contract deployed to: ${deployedRoles.address}`)

  // Deploy the Mint Contract
  const mintFactory = await ethers.getContractFactory("Mint", signer);
  const deployedMint = await mintFactory.deploy(deployedRoles.address);
  console.log(`Mint Contract deployed at: ${deployedMint.address}`);

  // Link the contracts
  // await deployedRoles.setMinter(deployedMint.address);
  // await deployedMint.setRoles(deployedRoles.address);

  // console.log(`Linked Roles address: ${await deployedMint.roles()}`);
  // console.log(`Linked Minter address: ${await deployedRoles.mint()}`);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1)
  })