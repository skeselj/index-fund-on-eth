// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

// contract IndexFund {
//     mapping(uint => string) public holdings;

//     constructor() {
//         holdings[0] = "my_string";
//     }

//     function temp() public {
//         holdings[1] = "my_string_2";
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

await deployedContract.temp();

console.log("About to print holdings");
console.log(await deployedContract.holdings);
console.log("Finished");

*/