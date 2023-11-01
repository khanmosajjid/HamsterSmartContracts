const { ethers, upgrades } = require("hardhat");

async function main() {
  const hamsterMarketV1Address = "YOUR_V1_CONTRACT_ADDRESS"; // replace with V1 contract address

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
