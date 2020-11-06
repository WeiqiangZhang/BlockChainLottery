const hre = require("hardhat");

async function main() {
  const MockToken = await hre.ethers.getContractFactory("MockToken");
  const mockToken = await MockToken.deploy();

  let token = await mockToken.deployed();

  console.log("MockToken deployed to:", mockToken.address);
  console.log("Total Supply:", (await token.totalSupply()).toNumber());
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
