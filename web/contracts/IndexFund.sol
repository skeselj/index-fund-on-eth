// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

/*

Conventions throughout:
  - Times are ms since epoch, durations are ms.
  - Prices are micro-ETH.

TODOs:
  - Performance optimization
    - Don't use uint64 for all ints.
  - Slippage optimization (including frontrunning)


Code used in https://sandbox.tenderly.co/skeselj/howling-zebra to test:

```

// Section 1.
const NUM_MS_IN_S = 1e6
const NUM_MS_IN_D = NUM_MS_IN_S * 60 * 24


// Section 2.
const contract = $contracts["MockIndexFund"];

// ethers is already injected
const provider = new ethers.providers.JsonRpcProvider($rpcUrl);
const factory = new ethers.ContractFactory(
    contract.abi, contract.evm.bytecode, provider.getSigner()
);


// Section 3.
// Args given to factory.deploy are passed to the constructor.
const deployedContract = await factory.deploy(7 * NUM_MS_IN_D);

let v = await deployedContract.getPrice(0);
console.log(`v = ${v}`);

```

*/


abstract contract IndexFund {
    /* Logic for managing an index fund.
    
    Requires implementation of methods related to:
        1. Retrieving information about assets.
        2. Executing buying and selling of assets.

    Example usage: 
        fund = IndexFund(1e6 * 60 * 24);    // Initialize a fund that rebalances every day.
        fund.inputFunds(0x37cA571343Ad20034f74464862857Fb9C1999acb, 1e6);   // Stefan input 1 ETH. Stefan owns 100% of the fund.
        fund.inputFunds(0x7cA571343Ad20034f74464862857Fb9C1999acb3, 5e5);   // Alice input 0.5 ETH. Stefan owns 66.67% of the fund, Alice owns 33.33%.
        // Wait a bit...
        fund.updateHoldings()
        // Wait a bit...
        fund.updateHoldings()
        // Wait a bit...
        fund.outputFunds(0x37cA571343Ad20034f74464862857Fb9C1999acb, 5e5);   // Stefan cashes out half his initial input. His ownership is not necessarily 50% now.
    */


    // (asset_id --> micro-units).
    mapping(uint64 => uint64) public holdings;
    // (asset_id --> price in micro-eth).
    mapping(uint64 => uint64) public prices;
    // (shareholder_address --> num_shares).
    mapping(address => uint64) public shareholders;

    // Measured in microseconds since epoch.
    uint64 public last_holding_update_time;
    // Measured in microseconds.
    uint64 public min_holding_update_diff_duration;

    // ETH will have ID 0. Other IDs will be assigned in order of discovery.
    // TODO: consider making EnumerableSet.IntSet (if this exists).
    uint64[] public asset_ids;

    uint64[] scratch_arr;

    constructor(uint64 _min_holding_update_diff_duration) {        
        min_holding_update_diff_duration = _min_holding_update_diff_duration;

        uint64[] memory _asset_ids = getAssets();
        for (uint64 asset_idx; asset_idx < _asset_ids.length; asset_idx++) {
            uint64 asset_id = _asset_ids[asset_idx];
            addAsset(asset_id, getPrice(asset_id));
        }
    }

    function addAsset(uint64 asset_id, uint64 price) public returns (string memory) {
        /* Idempotent.
        
        Arguments:
            price: in micro-eth.
        
        Returns:
            "" if successful. Otherwise will return an error message.

        */

        // If the asset has already been added, don't do anything.
        // TODO: consider using set instead.
        for (uint64 this_asset_idx = 0; this_asset_idx < asset_ids.length; this_asset_idx++) {
            uint64 this_asset_id = asset_ids[this_asset_idx];
            if (this_asset_id == asset_id) {
                return "";
            }
        }

        // Add to asset_ids and prices.
        asset_ids.push(asset_id);
        prices[asset_id] = price;

        return "";
    }

    function updateHoldings() public returns (string memory) {
        /* Compute the target holdings and try to make the holdings equal to that.
        
        Member variables will be updated all at once, or not at all.

        Returns:
            "" if successful. Otherwise will return an error message.

        */

        // Find target weights.
        // For every asset where we need to change the allocation, buy or sell the appropraite amount.
        // Update allocations.

        return "";
    }

    function inputFunds(address shareholder, uint64 eth_micro_units) public returns (string memory) {
        // TODO
    }

    function outputFunds(address shareholder, uint64 share_micro_units) public returns (string memory) {
        /*
        Arguments:
            share_micro_units: how much of the shareholder's share to output, in micro-units. 
                1,000,000 units = 100% of the shareholder's share.
        */

        // TODO
    }


    // Virtual methods.
    // Price in micro-ETH.
    function getAssets() public virtual returns (uint64[] memory);
        /* Get all asset IDs. */
    function getPrice(uint64 asset_id) public view virtual returns (uint64);
    function getAssetAbsoluteWeight(uint64 asset_id) public view virtual returns (uint64);

    function sellAssetQuantity(uint64 asset_id, uint64 quantity) public virtual returns (uint64);
        /* 
        Arguments:
            quantity: micro-units.
        Returns:
            Total proceeds, in micro-ETH.
        */
    function buyAssetQuantity(uint64 asset_id, uint64 quantity) public virtual returns (uint64);
        /* 
        Arguments:
            quantity: micro-units.
        Returns:
            Total cost, in micro-ETH.
        */


    // Debugging / inspection methods.
    
}


contract MockIndexFund is IndexFund {
    /* A dummy implementation of the virtual methods in IndexFund, used to test/mock the IndexFund class. */

    constructor(uint64 _min_holding_update_diff_duration) IndexFund(_min_holding_update_diff_duration) {        
        // For now, we just need the parent class constructor.
    }

    function getAssets() public virtual override returns (uint64[] memory) {
        // Just ETH.
        delete scratch_arr;
        scratch_arr.push(uint64(0));
        return scratch_arr;
    }

    function getPrice(uint64 asset_id) public view virtual override returns (uint64) {
        // 1 ETH = 1e6 micro-ETH.
        if (asset_id == 0) {
            return 1e6;
        }

        // Otherwise, return a hash-ish vlaue.
        return 1000 * (asset_id % 10);
    }

    function getAssetAbsoluteWeight(uint64 asset_id) public view virtual override returns (uint64) {
        // Otherwise, return a hash-ish vlaue.
        return 100 * (asset_id % 10);
    }

    function sellAssetQuantity(uint64 asset_id, uint64 quantity) public view virtual override returns (uint64) {
        /* Idealized version of selling some quantity of an asset.

        In reality, when executing on a DEX like Uniswap, there might be slippage. Further, the transaction could
        fail or timeout.
         */

        uint64 price = getPrice(asset_id);
        return quantity * price;        
    }

    function buyAssetQuantity(uint64 asset_id, uint64 quantity) public view virtual override returns (uint64) {
        /* Idealized version of buying some quantity of an asset.

        In reality, when executing on a DEX like Uniswap, there might be slippage. Further, the transaction could 
        fail or timeout.
         */
         
        uint64 price = getPrice(asset_id);
        return quantity * price;
    }
}
