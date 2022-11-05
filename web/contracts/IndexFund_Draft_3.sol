// SPDX-License-Identifier: MIT

// Here, I got inheritence to work.
// https://solidity-by-example.org/inheritance/

pragma solidity ^0.8.14;


// // interface IndexFundInterface {
// //     // function getMinHoldingUpdateDiffDuration() external view returns (uint64);
// // }


// // abstract contract IndexFund is IndexFundInterface {
// abstract contract IndexFund {

//     // // (asset_id --> micro-units).
//     // mapping(uint64 => uint64) public holdings;
//     // // (shareholder_address --> num_shares).
//     // mapping(address => uint64) public shareholders;
//     // // Measured in microseconds since epoch.
//     // uint64 public last_holding_update_time;
//     // // Measured in microseconds.
//     // uint64 min_holding_update_diff_duration;

//     // constructor(uint64 _min_holding_update_diff_duration) {
//     //     /*
        
//     //     Arguments:
//     //         _min_holding_update_diff_duration: See member variable.

//     //     */
        
//     //     // min_holding_update_diff_duration = _min_holding_update_diff_duration;
//     // }

//     function getMinHoldingUpdateDiffDuration() public view virtual returns (uint64);
// }

// contract MockIndexFund is IndexFund {
//     function getMinHoldingUpdateDiffDuration() public view virtual override returns (uint64) {
//         return 0;
//     }

//     // constructor(uint64 _min_holding_update_diff_duration) {
//     // }

//     // function getAssetAbsoluteWeight() public {
//     //     return 1;
//     // }

//     // function getMinHoldingUpdateDiffDuration() public override view returns (uint64) {
//     //     return 0;
//     // }
// }
