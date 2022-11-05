// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


// abstract contract IndexFund {

//     // (asset_id --> micro-units).
//     mapping(uint64 => uint64) public holdings;
//     // (shareholder_address --> num_shares).
//     mapping(address => uint64) public shareholders;
//     // Measured in microseconds since epoch.
//     uint64 public last_holding_update_time;
//     // Measured in microseconds.
//     uint64 min_holding_update_diff_duration;

//     constructor(uint64 _min_holding_update_diff_duration) {        
//         min_holding_update_diff_duration = _min_holding_update_diff_duration;
//     }

//     // Methods that must be implemented by an instantiation.
//     function getAssetAbsoluteWeight(uint64 asset_id) public view virtual returns (uint64);
//     // function getMinHoldingUpdateDiffDuration() public view virtual returns (uint64);
// }

// contract MockIndexFund is IndexFund {
//     constructor(uint64 _min_holding_update_diff_duration) IndexFund(_min_holding_update_diff_duration) {        
//     }

//     function getAssetAbsoluteWeight(uint64 asset_id) public view virtual override returns (uint64) {
//         return 122;
//     }
// }

/*

// ethers is already injected

const NUM_MS_IN_S = 1e6
const NUM_MS_IN_D = NUM_MS_IN_S * 60 * 24


const contract = $contracts["MockIndexFund"];

const provider = new ethers.providers.JsonRpcProvider($rpcUrl);
const factory = new ethers.ContractFactory(
    contract.abi, contract.evm.bytecode, provider.getSigner()
);

// Args given to factory.deploy are passed to the constructor.
const deployedContract = await factory.deploy(7 * NUM_MS_IN_D);


// console.log(await deployedContract.getAssetAbsoluteWeight(1));
v = await deployedContract.getAssetAbsoluteWeight(1);
console.log(`v = ${v}`);

*/