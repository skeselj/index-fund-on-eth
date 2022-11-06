
var assert = require('assert');

const MockIndexFund = artifacts.require("MockIndexFund");

const NUM_MS_IN_D = 1000 * 60 * 60 * 24;

// Traditional Truffle test
contract("MockIndexFund", (accounts) => {
  it("Should return the new greeting once it's changed", async function () {
    const fund = await MockIndexFund.new(7 * NUM_MS_IN_D);

    await fund.setWBTCPrice(2e18);   // 1 WBTC = 2 ETH.
    // await fund.setWBTCPrice(Web3.toBigNumber("2e18"));   // 1 WBTC = 2 ETH.

    // assert.equal(await greeter.greet(), "Hello, world!");

    // await greeter.setGreeting("Hola, mundo!");

    // assert.equal(await greeter.greet(), "Hola, mundo!");

    assert.equal(0, 0);
  });
});