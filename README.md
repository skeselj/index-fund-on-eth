# An Index Fund of crypto-assets on Ethereum

## Background
 - This was a project for the [ETHGlobal SF Hackathon 2022](https://ethglobal.com/events/ethsanfrancisco2022/home).
 - The more extensive project doc is [An Approach to On-Chain Index Funds (2022-11-06)](https://docs.google.com/document/d/1P7B8YbMYtgKWLpTUFDoFH_Krtiwo9xgKgCTuOfMV0Do/edit#heading=h.vv1754u0addx).


## What's the notable code?
 - [`web/contracts/IndexFund.sol`](https://github.com/skeselj/index-fund-on-eth/blob/main/web/contracts/IndexFund.sol) -- defines `IndexFund`, a core structure for implementing the index portfolio management strategy via a smart contract; and `MockIndexFund`, a child of `IndexFund` that has mocked versions of dependency methods.
 - [`web/contracts/UniswapIndexFund.sol`](https://github.com/skeselj/index-fund-on-eth/blob/main/web/contracts/UniswapIndexFund.sol) -- implements the external functions that `IndexFund` needs (for quoting and execution) using Uniswap!
 - [`web/test/testIndexFund.js`](https://github.com/skeselj/index-fund-on-eth/blob/main/web/test/testIndexFund.js) -- here you an see a user story for the `IndexFund` structure. A user story featuring two hypothetical users is executed using the mocked version.

## How do you run the notable code?
```
cd web
npm install
cd test
npx hardhat test
```
 
## Mainnet fork configuration
Set the `ALCHEMY_RPC_URL` environment variable to your private Ethereum RPC
endpoint before running tests that need a mainnet fork. Forking is disabled
when this variable is unset. Never commit the URL or its API key.
