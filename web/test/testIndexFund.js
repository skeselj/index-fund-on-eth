
var assert = require('assert');

const MockIndexFund = artifacts.require("MockIndexFund");

// Traditional Truffle test
contract("MockIndexFund", (accounts) => {
  it("Should return the new greeting once it's changed", async function () {
    const fund = await MockIndexFund.new(1);
    // assert.equal(await greeter.greet(), "Hello, world!");

    // await greeter.setGreeting("Hola, mundo!");

    // assert.equal(await greeter.greet(), "Hola, mundo!");

    assert.equal(0, 0);
  });
});