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
  mockLottery = await MockLottery.deploy(mockToken.address, 250, accounts[1].address, accounts[2].address);
  await mockLottery.deployed();
});

describe("MockLottery", function () {
  it("MockLottery should be initialized", async function () {
    assert.ok(mockLottery.address);
  });
  it("Tickets should initialize with the price of 250", async function () {
    expect(await mockLottery.ticketPrice()).to.equal(250);
  });
  it("Only admin can add manager", async function () {
    try {
      await mockLottery.connect(accounts[1]).addManager(accounts[2].address);
    } catch (err) {
      assert(true, err)
    };
    await mockLottery.addManager(accounts[3].address);
    expect(await mockLottery.getRoleMemberCount(await mockLottery.MANAGER_ROLE())).to.equal(3);
    await mockLottery.removeManager(accounts[3].address);
    expect(await mockLottery.getRoleMemberCount(await mockLottery.MANAGER_ROLE())).to.equal(2);
  });
  it("Can set ticket price properly", async function () {
    await mockLottery.setTicketPrice(69);
    expect(await mockLottery.ticketPrice()).to.equal(69);
  });
  it("Can select winner properly", async function () {
    await mockToken.connect(accounts[0]).increaseAllowance(mockLottery.address, 1000);
    await mockLottery.enter(4);
    expect((await mockToken.balanceOf(accounts[0].address)).toNumber()).to.equal(999000);
    expect(await mockLottery.prizePool()).to.equal((await mockToken.balanceOf(mockLottery.address)).toNumber());
    await mockLottery.selectWinner();
    expect((await mockToken.balanceOf(accounts[0].address)).toNumber()).to.equal(999950);
  });
});
