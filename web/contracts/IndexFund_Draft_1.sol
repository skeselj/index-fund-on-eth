// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

// contract IndexFund {
//     mapping(uint => string) public holdings;

//     constructor() {
//         holdings[0] = "my_string";
//     }

//     // This works.
//     function temp() public view returns (string memory) {
//         return "my_string_2";
//     }

//     // This prints "my_string".
//     function temp2() public view returns (string[] memory) {
//         string[] memory ret = new string[](1);

//         for (uint i = 0; i < 1 ; i++) {
//             ret[i] = holdings[i];
//         }

//         return ret;
//     }

// }

/*

// ethers is already injected

// Begin boilerplate.
const contract = $contracts["IndexFund"];

const provider = new ethers.providers.JsonRpcProvider($rpcUrl);
const factory = new ethers.ContractFactory(contract.abi, contract.evm.bytecode, provider.getSigner());

// Constructor args are given to deploy.
const deployedContract = await factory.deploy();
// End boilerplate.

deployedContract.temp();

console.log("About to print holdings");
console.log(await deployedContract.temp2());
console.log("Finished");

*/