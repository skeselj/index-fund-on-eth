// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


// contract IndexFund {

//     // (asset_id --> micro-units).
//     mapping(uint64 => uint64) public holdings;
//     // (shareholder_address --> num_shares).
//     mapping(address => uint64) public shareholders;
//     // Measured in microseconds since epoch.
//     uint64 public last_holding_update_time;
//     // Measured in microseconds.
//     uint64 min_holding_update_diff_duration;

//     constructor(uint64 _min_holding_update_diff_duration) {
//         /*
        
//         Arguments:
//             _min_holding_update_diff_duration: See member variable.

//         */

//         min_holding_update_diff_duration = _min_holding_update_diff_duration;
//     }

//     function getMinHoldingUpdateDiffDuration() public view returns (uint64) {
//         return min_holding_update_diff_duration;
//     }

//     function getAssetAbsoluteWeight() external;
// }

// contract MockIndexFund is IndexFund {

//     function getAssetAbsoluteWeight() public {
//         return 1;
//     }
// }
