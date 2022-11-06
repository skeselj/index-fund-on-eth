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

async function printDebugInfo(fund) {
  /* Print info about holdings and shareholders. */

  console.log("[actual]");

  console.log("\tHoldings of the fund:");
  await fund.writeHoldingsDebugInfo();
  
  holding_debug_info = await fund.getHoldingDebugInfo();
  let asset_ids = holding_debug_info[0];
  let holdings = holding_debug_info[1];

  for (let asset_idx = 0; asset_idx < asset_ids.length; asset_idx++) {
    asset_id = asset_ids[asset_idx];
    holding = holdings[asset_idx];
    
    console.log(
      `\t\tFor asset_id = ${asset_id}, holding = ${holding / 1e18} x 1e18`
    );
  }

  console.log("\tShareholders of the fund:");
  await fund.writeShareholderDebugInfo();

  shareholder_debug_info = await fund.getShareholderDebugInfo();
  let shareholders = shareholder_debug_info[0];
  let shares = shareholder_debug_info[1];

  for (let shareholder_idx = 0; shareholder_idx < shareholders.length; shareholder_idx++) {
    shareholder = shareholders[shareholder_idx];
    share = shares[shareholder_idx];

    console.log(
      `\t\tFor shareholder = ${shareholder}, share = ${share / 1e6} x 1e6`
    );
  }
}

contract("MockIndexFund", (accounts) => {
  it("The core demo / testing story: Alice and Bob", async function () {
    const fund = await MockIndexFund.new(7 * NUM_MS_IN_D);

    // Setup initial prices and market caps.
    await fund.setWBTCPrice(new BigNumber("2e18"));   // 1 WBTC = 2 ETH.
    await fund.setETHMktcap(new BigNumber("1e12"));   // ETH has 1T market cap.
    await fund.setWBTCMktCap(new BigNumber("1.5e12"));   // WBTC has 1.5T market cap.

    // Alice inputs 1 ETH. Alice should own 100% of the fund.
    await fund.inputFunds(ALICE_ADDR, new BigNumber("1e18"));   
    // Bob inputs 0.5 ETH. Alice should own 66.67% of the fund, and Bob 33.33%.
    await fund.inputFunds(BOB_ADDR, new BigNumber("5e17"));
    // Update holdings. 
    await fund.updateHoldings();
    console.log(
      "\n[expected] We have setup the fund. Alice should own 66.67%, and Bob should own 33.33%."
    );

    await printDebugInfo(fund);
 
    await fund.setETHMktcap(new BigNumber("0.8e12"));
    await fund.updateHoldings();
    console.log(
      "\n[expected] The market cap of ETH has gone down from 1e12 to 0.8e12.\n" + 
      "\tOur holdings of ETH should go down."
    );

    await printDebugInfo(fund);

    await fund.setETHMktcap(new BigNumber("1.3e12"));
    await fund.updateHoldings();
    console.log(
      "\n[expected] The market cap of ETH has gone up from 0.8e12 to 1.3e12.\n" + 
      "\tOur holdings of ETH should go up, higher than what they were before."
    );

    await printDebugInfo(fund);

    await fund.outputFunds(
      ALICE_ADDR, 5e5,
      false   // Do the internal accounting, but don't actually do the transfer.
    );
    await fund.updateHoldings();
    console.log(
      "\n[expected] Alice has withdrawn half her holdings, so her relative share should " + 
      "shrink to (x/2) / (x/2 + (1-x)), \nwhere x was her old share. And, the ETH she takes out " + 
      "should be gone."
    );

    await printDebugInfo(fund);
  });
});
