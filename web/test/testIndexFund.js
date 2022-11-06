// 

const Assert = require('assert');
const Web3 = require("web3");
const BigNumber = require("bignumber.js");

const MockIndexFund = artifacts.require("MockIndexFund");

const NUM_MS_IN_D = 1000 * 60 * 60 * 24;
// This is is actually Stefan's address.
const ALICE_ADDR = "0x37cA571343Ad20034f74464862857Fb9C1999acb";
// This is actually Vitalik's address.
const BOB_ADDR = "0xab5801a7d398351b8be11c439e05c5b3259aec9b";

async function printHoldings(fund) {
  await fund.writeHoldingsDebugInfo();
  
  holding_debug_info = await fund.getHoldingDebugInfo();
  let asset_ids = holding_debug_info[0];
  let holdings = holding_debug_info[1];

  for (let asset_idx = 0; asset_idx < asset_ids.length; asset_idx++) {
    asset_id = asset_ids[asset_idx];
    holding = holdings[asset_idx];
    
    console.log(
      `asset_id, holding = ${asset_id}, ${holding / 1e18} x 1e18`
    );
  }
}

// Traditional Truffle test
contract("MockIndexFund", (accounts) => {
  it("The core demo / testing story: Alice and Bob", async function () {
    const fund = await MockIndexFund.new(7 * NUM_MS_IN_D);

    // Mock prices and market caps.
    await fund.setWBTCPrice(new BigNumber("2e18"));   // 1 WBTC = 2 ETH.
    await fund.setETHMktcap(new BigNumber("1e12"));   // ETH has 1T market cap.
    await fund.setWBTCMktCap(new BigNumber("1.5e12"));   // WBTC has 1.5T market cap.

    // Alice inputs 1 ETH. Alice owns 100% of the fund.
    await fund.inputFunds(ALICE_ADDR, new BigNumber("1e18"));   
    // Bob inputs 0.5 ETH. Alice owns 66.67% of the fund, Bob owns 33.33%.
    await fund.inputFunds(BOB_ADDR, new BigNumber("5e17"));
    // Update holdings. 
    await fund.updateHoldings();

    console.log("I finished updating the holdings.");
    printHoldings(fund);

    Assert.equal(0, 0);
  });
});
