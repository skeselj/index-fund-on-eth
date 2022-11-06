# An Index Fund of crypto-assets on the Ethereum blockchain

## Background
 - This was a project for the ETHGlobal SF Hackathon 2022.
 - The more extensive project doc is [An Approach to On-Chain Index Funds (2022-11-06)](https://docs.google.com/document/d/1P7B8YbMYtgKWLpTUFDoFH_Krtiwo9xgKgCTuOfMV0Do/edit#heading=h.vv1754u0addx).


## What is non-boilerplate in this repo?
 - `web/contracts/IndexFund.sol` -- defines `IndexFund`, a core structure for implementing the index portfolio management strategy via a smart contract; and `MockIndexFund`, a child of `IndexFund` that has mocked versions of dependency methods.
 - `web/test/testIndexFund.js` -- here you an see a user story for the `IndexFund` structure. A mocked version is used, and a user story featuring two hypothetical users is executed.

## How do I use this repo?
```
cd web
npm install
cd test
npx hardhat test
```
