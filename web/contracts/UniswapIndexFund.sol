pragma solidity ^0.6.6;

import "./IndexFund.sol";

// https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract UniswapIndexFund is IndexFund {
    /* Use Uniswap v2 to implement the external (quote and execute) functions in IndexFund!
    
    Only using 5 hard-coded assets. TODO: replace this with a piece of logic that queries for all
    assets on Uniswap.

    */
    
    address public pair_factory;
    IUniswapV2Router02 private router;
    mapping(uint256 => address) public asset_id_to_addr;
    mapping(uint256 => string) public asset_id_to_name;

    uint256[] temp_ary1;
    address[] temp_ary2;

    constructor(uint256 _min_holding_update_diff_duration, address _pair_factory, address _router_factory)
        public IndexFund(_min_holding_update_diff_duration)
    {
        pair_factory = _pair_factory;
        router = IUniswapV2Router02(_router_factory); 
        // For now, we just need the parent class constructor.

        // Took the top 5 by liquidity in https://v2.info.uniswap.org/tokens (excluding stablecoins).
        // TODO: query for this programmaticlaly.
        asset_id_to_name[0] = "WETH";
        asset_id_to_name[1] = "WISE";
        asset_id_to_name[2] = "HANU";
        asset_id_to_name[3] = "ACR";
        asset_id_to_name[4] = "FNK";

        asset_id_to_addr[0] = address(0x00c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2);
        asset_id_to_addr[1] = address(0x0066a0f676479cee1d7373f3dc2e2952778bff5bd6);
        asset_id_to_addr[2] = address(0x0072e5390edb7727e3d4e3436451dadaff675dbcc0);
        asset_id_to_addr[3] = address(0x0076306f029f8f99effe509534037ba7030999e3cf);
        asset_id_to_addr[4] = address(0x00b5fe099475d3030dde498c3bb6f3854f762a48ad);
    }

    function getAssets() public virtual override returns (uint256[] memory) {
        delete temp_ary1;

        temp_ary1.push(0);
        temp_ary1.push(1);
        temp_ary1.push(2);
        temp_ary1.push(3);
        temp_ary1.push(4);
        
        return temp_ary1;
    }

    function getQuoteInfo(uint256 asset_id) public view returns (uint256, uint256, uint256) {
        address eth_addr = asset_id_to_addr[0]; 
        address asset_addr = asset_id_to_addr[asset_id]; 

        IUniswapV2Pair eth_to_asset_pair = IUniswapV2Pair(
            UniswapV2Library.pairFor(pair_factory, eth_addr, asset_addr)
        );
        // totalSupply = pair.totalSupply();
        (uint256 reserves0, uint256 reserves1,) = eth_to_asset_pair.getReserves();
        (uint256 reserve_eth, uint256 reserve_asset) = (
            eth_addr == eth_to_asset_pair.token0() ? (reserves0, reserves1) : (reserves1, reserves0)
        );

        uint256 asset_price_eth = UniswapV2Library.quote(1, reserve_eth, reserve_asset);
        uint256 asset_price_wei = asset_price_eth * 1e18;

        return (reserve_eth, reserve_asset, asset_price_wei);
    }

    function getPrice(uint256 asset_id) public view virtual override returns (uint256) {
        if (asset_id == 0) {
            return 1e18;
        }

        (uint256 reserve_eth, uint256 reserve_asset, uint256 asset_price_wei) = getQuoteInfo(asset_id);

        return asset_price_wei;
    }

    function getAssetAbsoluteWeight(uint256 asset_id) public view virtual override returns (uint256) {
        (uint256 reserve_eth, uint256 reserve_asset, uint256 asset_price_wei) = getQuoteInfo(asset_id);

        if (asset_id == 0) {
            asset_price_wei = 1e18;
        }

        // Market cap. = P x Q.
        return asset_price_wei * reserve_asset;
    }

    function sellAssetQuantity(uint256 asset_id, uint256 quantity) public virtual override returns (uint256) {
        (uint256 reserve_eth, uint256 reserve_asset, uint256 asset_price_wei) = getQuoteInfo(asset_id);

        temp_ary2.push(asset_id_to_addr[asset_id]);
        temp_ary2.push(asset_id_to_addr[0]);

        uint256 expected_amount_of_eth = quantity * asset_price_wei * 1e18; 
    
        uint256[] memory proceeds = router.swapExactTokensForETH(
            quantity,   // amountIn
            expected_amount_of_eth,   // amountOutMin,
            temp_ary2,   // path 
            address(this),   // to
            block.timestamp + 600   // deadline
        );

        return proceeds[0];
    }

    function buyAssetQuantity(uint256 asset_id, uint256 quantity) public virtual override returns (uint256) {
        (uint256 reserve_eth, uint256 reserve_asset, uint256 asset_price_wei) = getQuoteInfo(asset_id);

        temp_ary2.push(asset_id_to_addr[0]);
        temp_ary2.push(asset_id_to_addr[asset_id]);

        uint256 expected_amount_of_eth = quantity * asset_price_wei * 1e18;

        uint256[] memory proceeds = router.swapETHForExactTokens(
            quantity,   // amountOut
            temp_ary2,   // path 
            address(this),   // to
            block.timestamp + 600   // deadline
        );

        return proceeds[1];
    }    
}