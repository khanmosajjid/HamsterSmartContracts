require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("@openzeppelin/hardhat-upgrades");

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  networks: {
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/rfCruuBJ6-ND7sPx8qfywX0PjKWcmIQq",
      accounts: [
        "c4abff6be9f78ab8247d1b8df91c350c3c7614af3ed3d514731bc146165e3dd1",
      ],
    },
  },
  etherscan: {
    apiKey: "NET91B9KDU24AS39FRIKRDNYIQ9UUYJ51K",
  },
};
