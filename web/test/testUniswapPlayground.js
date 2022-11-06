
const UniswapV2FactoryBytecode = require('@uniswap/v2-core/build/UniswapV2Factory.json').bytecode
const Web3 = require("web3");

const MyUniswapClass = artifacts.require("MyUniswapClass");

const UNISWAP_PAIR_ADDR = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
const UNISWAP_ROUTER_ADDR = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

const UNISWAP_WETH_ADDR = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
const UNISWAP_WISE_ADDR = "0x66a0f676479cee1d7373f3dc2e2952778bff5bd6";
const UNISWAP_WBTC_ADDR = "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599";
const UNISWAP_ETH_PEEPS_PAIR_ADDR = "0x6cbcd84abcfbb411426dc21a621fe9a68b985bf4"


contract("MyUniswapClass", (accounts) => {
  it("The main test", async function () {
      
      // I need the address of the factory.

      // const my_uniswap_class = await MyUniswapClass.new(UniswapV2Fact0oryBytecode.abi);
      // const my_uniswap_class = await MyUniswapClass.new(UniswapV2FactoryBytecode.evm.bytecode.object);
      const my_uniswap_class = await MyUniswapClass.new(UNISWAP_PAIR_ADDR, UNISWAP_ROUTER_ADDR);

      let pair_info = await my_uniswap_class.pairInfo(UNISWAP_WETH_ADDR, UNISWAP_WISE_ADDR);
      console.log(
        `Object.keys(pair_info) = ${Object.keys(pair_info)}`
      );

      let reserve_weth = pair_info[0];
      let reserve_wise = pair_info[1];
      let total_supply = pair_info[2];

      console.log(
        `reserve_weth = ${reserve_weth}, ` + 
        `reserve_wise = ${reserve_wise}, `
      );

      // Test router.
      // let quote_for_wise_in_eth = await my_uniswap_class.getQuote(UNISWAP_WETH_ADDR, UNISWAP_WISE_ADDR);
      // console.log(
      //   `quote_for_wise_in_eth = ${quote_for_wise_in_eth}`
      // );

  });
});
