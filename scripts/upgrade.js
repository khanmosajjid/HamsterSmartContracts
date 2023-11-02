const { ethers, upgrades } = require("hardhat");

async function main() {
  const hamsterMarketV1Address = "0x9D060868daDDf3e4602f87a9794E4D1Ef390e878"; // replace with V1 contract address

  const HamsterMarketPlaceV2 = await ethers.getContractFactory(
    "HamsterMarketPlaceV2"
  );
  console.log("Upgrading HamsterMarketPlace...");
  const upgradedHamsterMarket = await upgrades.upgradeProxy(
    hamsterMarketV1Address,
    HamsterMarketPlaceV2
  );

  console.log("HamsterMarketPlace upgraded to:", upgradedHamsterMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
