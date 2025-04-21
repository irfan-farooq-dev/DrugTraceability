require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  settings: {
    optimizer: {
      enabled: true,
      runs: 50  // lower runs = smaller size
    }
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:7545", // Ganache default
      accounts: [
        "0xaa23b807c75073fd65b872e0811713da6323ad781bf0a23e2e37036561eebb5c"
      ],
    },
  },
};
