require("@nomiclabs/hardhat-ethers");
// require("@nomiclabs/hardhat-waffle"); // if needed for testing
// require("chai"); // if needed

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  settings: {
    optimizer: {
      enabled: true,
      runs: 50  // lower runs = smaller size
    },
    viaIR: true
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545", // Ganache default
      // chainId: 1337 
    },
  }
};
