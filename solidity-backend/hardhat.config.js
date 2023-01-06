require('hardhat-deploy');
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork:"hardhat",
  solidity: "0.8.17",
  networks:{
    hardhat:{
      chainId:31337,
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 5,
      blockConfirmations: 6,
  },
  },
  namedAccounts:{
    deployer:{
      default:0,
      1:0,
    },
  },
  mocha:{
    timeout:500000,
  }
};
