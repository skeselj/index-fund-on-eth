// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

/*

Conventions throughout:
  - Times are ms since epoch, durations are ms.
  - Prices are micro-ETH. TODO: change this to wei, which is 1e-18 ETH. And change ints to uint256.

TODOs:
  - Performance optimization.
  - Slippage optimization (including frontrunning).


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
        fund.inputFunds(0x37cA571343Ad20034f74464862857Fb9C1999acb, 1e18);   // Alice input 1 ETH. Alce owns 100% of the fund.
        fund.inputFunds(0x7cA571343Ad20034f74464862857Fb9C1999acb3, 5e17);   // Bob input 0.5 ETH. Alice owns 66.67% of the fund, Bob owns 33.33%.
        // Wait a bit...
        fund.updateHoldings()
        // Wait a bit...
        fund.updateHoldings()
        // Wait a bit...
        fund.outputFunds(0x37cA571343Ad20034f74464862857Fb9C1999acb, 5e17);   // Alice cashes out half her initial input. His ownership is not necessarily 50% now.
    */

    // (asset_id --> in units of (10-18)th of a whole (1)).
    mapping(uint256 => uint256) public holdings;
    // (asset_id --> price in wei).
    mapping(uint256 => uint256) public prices;
    // (shareholder_address --> micro-shares).
    mapping(address => uint256) public shareholder_to_share;

    // Measured in microseconds since epoch.
    uint256 public last_holding_update_time;
    // Measured in microseconds.
    uint256 public min_holding_update_diff_duration;

    // ETH will have ID 0. Other IDs will be assigned in order of discovery.
    // TODO: consider making EnumerableSet.IntSet (if this exists).
    uint256[] public asset_ids;
    //
    address[] public shareholders;

    // Temp data structures that need to be cleaned up.
    uint256[] public scratch_arr;
    mapping(address => uint256) public shareholder_to_wei;
    // Units of (10-18)th of a whole (1).
    mapping(uint256 => uint256) public target_holdings; 
    uint256[] public debug_ary1;
    uint256[] public debug_ary2;


    constructor(uint256 _min_holding_update_diff_duration) {        
        min_holding_update_diff_duration = _min_holding_update_diff_duration;
        refreshAssets();
    }

    function refreshAssets() public {
        // Erase prices.
        for (uint256 asset_idx = 0; asset_idx < asset_ids.length; asset_idx++) {
            prices[asset_ids[asset_idx]] = 0;
        }
        // Erase asset_ids.
        delete asset_ids;
        // Re-make asset_ids.
        asset_ids = getAssets();
        // Re-make prices.
        for (uint256 asset_idx = 0; asset_idx < asset_ids.length; asset_idx++) {
            uint256 asset_id = asset_ids[asset_idx]; 
            prices[asset_id] = getPrice(asset_id);
        }
    }

    function updateHoldings() public returns (string memory) {
        /* Compute the target holdings and try to make the holdings equal to that.
        
        Member variables will be updated all at once, or not at all.

        Returns:
            "" if successful. Otherwise will return an error message.

        */

        // Find target_holdings.
        refreshAssets();
        uint256 existing_funds_wei = getExistingFundsWei();
        
        uint256 total_absolute_weight = 0;
        // First pass: compute total weight.
        for (uint256 asset_idx; asset_idx < asset_ids.length; asset_idx++) {
            uint256 asset_id = asset_ids[asset_idx]; 

            uint256 this_absolute_weight = getAssetAbsoluteWeight(asset_id);

            total_absolute_weight += this_absolute_weight;
        }

        // Second pass: set targets.
        for (uint256 asset_idx; asset_idx < asset_ids.length; asset_idx++) {
            uint256 asset_id = asset_ids[asset_idx]; 
            
            uint256 this_absolute_weight = getAssetAbsoluteWeight(asset_id);
            uint256 price = prices[asset_id];

            target_holdings[asset_id] = (
                1e18 * 
                existing_funds_wei * 
                this_absolute_weight / total_absolute_weight /
                price 
            );
        }

        // For every asset where we need to change the allocation, buy or sell the appropraite
        // amount, and update holdings.
        for (uint256 asset_idx; asset_idx < asset_ids.length; asset_idx++) {
            uint256 asset_id = asset_ids[asset_idx]; 

            uint256 current_holding = holdings[asset_id];
            uint256 target_holding = target_holdings[asset_id];

            if (current_holding > target_holding) {
                uint256 quantity_to_sell = current_holding - target_holding; 
                sellAssetQuantity(asset_id, quantity_to_sell / 1e18);
                holdings[asset_id] -= quantity_to_sell;
            }
            if (current_holding < target_holding) {
                uint256 quantity_to_buy = target_holding - current_holding; 
                buyAssetQuantity(asset_id, quantity_to_buy / 1e18);
                holdings[asset_id] += quantity_to_buy;
            }
        }

        return "";
    }

    function getExistingFundsWei() public view returns (uint256) {
        uint256 existing_funds_wei = 0;

        for (uint256 this_asset_idx = 0; this_asset_idx < asset_ids.length; this_asset_idx++) {
            uint256 this_asset_id = asset_ids[this_asset_idx];
            
            existing_funds_wei += (
                prices[this_asset_id] *
                holdings[this_asset_id] / 1e18
            );
        }

        return existing_funds_wei; 
    }

    function updateShareHolderToShare(uint256 existing_funds_wei) public {
        for (uint256 shareholder_idx = 0; shareholder_idx < shareholders.length; shareholder_idx++) {
            address shareholder = shareholders[shareholder_idx];

            shareholder_to_share[shareholder] = (
                1e6 *
                shareholder_to_wei[shareholder] / existing_funds_wei
            );
            // Clean up shareholder_to_wei.
            shareholder_to_wei[shareholder] = 0; 
        }
    }

    // receive and fallback are required to receive ETH.
    receive() external payable {
        /* receive is used (instead of fallback) when msg.data is empty. */
        inputFunds(msg.sender, msg.value);
    }
    fallback() external payable {
        /* fallback is used (instead of receive) when msg.data is empty. */
        inputFunds(msg.sender, msg.value);
    }
    function inputFunds(address depositing_shareholder, uint256 deposited_wei) public returns (string memory) {
        /* Update state to take into account that depositing_shareholder deposited deposited_wei. 
        
        Assumption: the ETH that was sent to this contract is stored in this contract. 
        */

        uint256 existing_funds_wei = getExistingFundsWei();

        // Compute shareholder_to_wei, and then update it, and then convert back to holdings.
        for (uint256 shareholder_idx = 0; shareholder_idx < shareholders.length; shareholder_idx++) {
            address shareholder = shareholders[shareholder_idx];

            shareholder_to_wei[shareholder] = (
                existing_funds_wei *
                shareholder_to_share[shareholder] / 1e6
            );
        }

        shareholder_to_wei[depositing_shareholder] += deposited_wei;
        existing_funds_wei += deposited_wei;
        // TODO: log that this input happened, on-chain.

        // Maybe add a new shareholder.
        bool depositing_shareholder_exists = false;

        for (uint256 shareholder_idx = 0; shareholder_idx < shareholders.length; shareholder_idx++) {
            address shareholder = shareholders[shareholder_idx];

            if (shareholder == depositing_shareholder) {
                depositing_shareholder_exists = true;
                break;
            }
        }

        if (!depositing_shareholder_exists) {
            // TODO: use a set.
            shareholders.push(depositing_shareholder);
        }

        // Update shareholder_to_share.
        updateShareHolderToShare(existing_funds_wei);

        // Update holdings.
        holdings[0] += deposited_wei;

        return "";
    }

    function outputFunds(
        address payable withdrawing_shareholder, uint256 withdrawn_share_micro_units
    ) public returns (string memory) {
        /*
        Arguments:
            share_micro_units: how much of the shareholder's share to output, in micro-units. 
                1,000,000 units = 100% of the shareholder's share.
        */

        uint256 existing_funds_wei = getExistingFundsWei();

        for (uint256 shareholder_idx = 0; shareholder_idx < shareholders.length; shareholder_idx++) {
            address shareholder = shareholders[shareholder_idx];

            shareholder_to_wei[shareholder] = (
                existing_funds_wei *
                shareholder_to_share[shareholder] / 1e6
            );
        }

        uint256 withdrawing_shareholder_share = shareholder_to_share[withdrawing_shareholder];
        uint256 withdrawl_wei = (
            existing_funds_wei *
            (1e6 * withdrawing_shareholder_share) *
            (1e6 * withdrawn_share_micro_units)
        );

        // Update shareholder_to_share, and maybe shareholders.
        shareholder_to_wei[withdrawing_shareholder] -= withdrawl_wei;
        existing_funds_wei -= withdrawl_wei;
        // TODO: log that this output happened on chain.

        updateShareHolderToShare(existing_funds_wei);

        // TODO: if withdrawn_share_micro_units == 100%, remove withdrawing_shareholder from 
        // shareholders.

        // Update holdings.
        // TODO: check if there is enough ETH to let the person cash out.
        holdings[0] -= withdrawl_wei;

        // Complete the transfer.
        withdrawing_shareholder.transfer(withdrawl_wei);

        return "";
    }


    // Virtual methods.
    function getAssets() public virtual returns (uint256[] memory);
        /* Get all asset IDs. The IDs need to be the same from call to call. */
    function getPrice(uint256 asset_id) public view virtual returns (uint256);
        /** Price in wei. */
    function getAssetAbsoluteWeight(uint256 asset_id) public view virtual returns (uint256);

    function sellAssetQuantity(uint256 asset_id, uint256 quantity) public virtual returns (uint256);
        /* 
        Arguments:
            quantity: in whole units.
        Returns:
            Total proceeds, in wei.
        */
    function buyAssetQuantity(uint256 asset_id, uint256 quantity) public virtual returns (uint256);
        /* 
        Arguments:
            quantity: in whole units.
        Returns:
            Total cost, in wei.
        */


    // Debugging / inspection methods.
    function writeHoldingsDebugInfo() public {        
        for (uint256 asset_idx; asset_idx < asset_ids.length; asset_idx++) {
            uint256 asset_id = asset_ids[asset_idx];
            uint256 holding = holdings[asset_id];

            debug_ary1.push(asset_id);
            debug_ary2.push(holding);
        }
    }
    function getHoldingDebugInfo() public view returns (uint256[] memory, uint256[] memory) {
        return (debug_ary1, debug_ary2);
    }
}



contract MockIndexFund is IndexFund {
    /* A dummy implementation of the virtual methods in IndexFund, used to test/mock IndexFund.
    
    Only 2 assets are supported: ETH (id=0), WBTC (id=1).
    
    */

    uint256 public wbtc_price;

    uint256 public eth_mktcap;
    uint256 public wbtc_mktcap;

    constructor(uint256 _min_holding_update_diff_duration) IndexFund(_min_holding_update_diff_duration) {        
        // For now, we just need the parent class constructor.
    }

    function setWBTCPrice(uint256 _wbtc_price) public {
        wbtc_price = _wbtc_price;
    }

    function setETHMktcap(uint256 _eth_mktcap) public {
        eth_mktcap = _eth_mktcap;
    }

    function setWBTCMktCap(uint256 _wbtc_mktcap) public {
        wbtc_mktcap = _wbtc_mktcap;
    }

    function getAssets() public virtual override returns (uint256[] memory) {
        // Just ETH.
        delete scratch_arr;
        scratch_arr.push(uint256(0));
        scratch_arr.push(uint256(1));
        return scratch_arr;
    }

    function getPrice(uint256 asset_id) public view virtual override returns (uint256) {
        if (asset_id == 0) {
            // 1 ETH = 1e18 wei, always.
            return 1e18;
        }
        if (asset_id == 1) {
            return wbtc_price;
        }
        require(0 > 1, "asset_id is invalid");
        return 0;
    }

    function getAssetAbsoluteWeight(uint256 asset_id) public view virtual override returns (uint256) {
        if (asset_id == 0) {
            return eth_mktcap;
        }
        if (asset_id == 1) {
            return wbtc_mktcap;
        }
        require(0 > 1, "asset_id is invalid");
        return 0;
    }

    function sellAssetQuantity(uint256 asset_id, uint256 quantity) public view virtual override returns (uint256) {
        /* Idealized version of selling some quantity of an asset.

        In reality, when executing on a DEX like Uniswap, there might be slippage. Further, the transaction could
        fail or timeout.
         */

        uint256 price = getPrice(asset_id);   // is in wei.
        return quantity * price;        
    }

    function buyAssetQuantity(uint256 asset_id, uint256 quantity) public view virtual override returns (uint256) {
        /* Idealized version of buying some quantity of an asset.

        In reality, when executing on a DEX like Uniswap, there might be slippage. Further, the transaction could 
        fail or timeout.
         */
         
        uint256 price = getPrice(asset_id);   // is in wei.
        return quantity * price;
    }
}
