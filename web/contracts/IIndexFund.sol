// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IndexFund {
    // Core methods implemented by IndexFund.
    // Refresh our knowledge of asset prices and market caps.
    function refreshAssets() external;
    // Rebalance our holdings.
    function updateHoldings() external returns (string memory);
    function inputFunds(address depositing_shareholder, uint256 deposited_wei) 
        external returns (string memory);
    function outputFunds(
        address payable withdrawing_shareholder, uint256 withdrawn_share_micro_units,
        bool do_transfer
    ) external returns (string memory);

    // Virtual methods that rely on an outside system. Can be mocked.
    // Return IDs of all assets we consider.
    function getAssets() external returns (uint256[] memory);
    function getPrice(uint256 asset_id) external view returns (uint256);
    // Absolute weight usually means market cap., but this can be edited.
    function getAssetAbsoluteWeight(uint256 asset_id) external view returns (uint256);
    // Return proceeds (in sell case), or cost (in buy case); both in wei.
    function sellAssetQuantity(uint256 asset_id, uint256 quantity) external returns (uint256);
    function buyAssetQuantity(uint256 asset_id, uint256 quantity) external returns (uint256);
}