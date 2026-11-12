require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-truffle5");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.17" 
      },
      {
        version: "0.6.6"
      }
    ]
  },
  networks: {
    hardhat: {
      forking: {
        enabled: Boolean(process.env.ALCHEMY_RPC_URL),
        url: process.env.ALCHEMY_RPC_URL || "",
      }
    }
  }
};
