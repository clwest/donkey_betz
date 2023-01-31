const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Roles Contract', () => {
    let roles;
    let signer;

    beforeEach(async () => {
        // Get a signer
        signer = await ethers.getSigner();
        // Deploy the Roles contract
        const rolesFactory = await ethers.getContractFactory("Roles");
        roles = await rolesFactory.deploy();
        await roles.deployed();
    });

    it('should have a valid deploy address', async () => {
        expect(roles.address).to.not.be.null;
    });

    it('should be able to add a role', async () => {
        const role = "ADMIN_ROLE";
        const account = await signer.getAddress();
        await roles.grantRole(role, account);
        const hasRole = await roles.hasRole(role, account);
        expect(hasRole).to.be.true;
    });

    it('should be able to remove a role', async () => {
        const role = "ADMIN_ROLE";
        const account = await signer.getAddress();
        await roles.grantRole(role, account);
        await roles.revokeRole(role, account);
        const hasRole = await roles.hasRole(role, account);
        expect(hasRole).to.be.false;
    });
});
