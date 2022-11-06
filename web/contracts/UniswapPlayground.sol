// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

// https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
// import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Router02.sol';



contract MyUniswapClass {

    address public pair_factory;
    address public router_factory;

    constructor(address _pair_factory, address _router_factory) public {
        pair_factory = _pair_factory;
        router_factory = _router_factory;
    }

    function pairInfo(address tokenA, address tokenB) public view
        returns (uint reserveA, uint reserveB, uint totalSupply)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(pair_factory, tokenA, tokenB));
        totalSupply = pair.totalSupply();
        (uint reserves0, uint reserves1,) = pair.getReserves();
        (reserveA, reserveB) = tokenA == pair.token0() ? (reserves0, reserves1) : (reserves1, reserves0);
    }

    // function getQuote(address tokenA, address tokenB) returns (uint256) {
    //     // The quote in ETH.
    //     return UniswapV2Library.quote(1, tokenA, tokenB);
    // } 
}
