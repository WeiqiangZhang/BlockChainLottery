const { expect, assert } = require("chai");

let MockToken;
let mockToken;
let accounts;
let MockLottery;
let mockLottery;

beforeEach(async function () {
  MockToken = await hre.ethers.getContractFactory("MockToken");
  mockToken = await MockToken.deploy();
  accounts = await ethers.getSigners();
  await mockToken.deployed();
  MockLottery = await hre.ethers.getContractFactory("MockLottery");
  mockLottery = await MockLottery.deploy(mockToken.address, 250);
  await mockLottery.deployed();
});

describe("MockLottery", function () {
  it("MockLottery should be initialized", async function () {
    assert.ok(mockLottery.address);
  });
});

