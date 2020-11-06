const { expect } = require("chai");

let MockToken;
let mockToken;
let accounts;

beforeEach(async function () {
  MockToken = await hre.ethers.getContractFactory("MockToken");
  mockToken = await MockToken.deploy();
  accounts = await ethers.getSigners();
  await mockToken.deployed();
});

describe("MockToken", function () {
  it("MockToken should initialize with 1,000,000", async function () {
    expect((await mockToken.totalSupply()).toNumber()).to.equal(1000000);
  });
  it("MockToken should initialize with proper name", async function () {
    expect(await mockToken.name()).to.equal("MockToken");
  });
  it("MockToken should initialize with proper symbol", async function () {
    expect(await mockToken.symbol()).to.equal("MOK");
  });
  it("Account 0 should have 1,000,000 Mock Tokens", async function () {
    expect((await mockToken.balanceOf(accounts[0].address)).toNumber()).to.equal(1000000);
  });
  it("Transfer properly", async function () {
    await mockToken.transfer(accounts[1].address, 500000);
    expect((await mockToken.balanceOf(accounts[0].address)).toNumber()).to.equal(500000);
    expect((await mockToken.balanceOf(accounts[1].address)).toNumber()).to.equal(500000);
  });
});
