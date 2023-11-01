const { ethers, upgrades } = require("hardhat");

async function main() {
  const hamsterCollectionV1Address =
    "0x2c96fD456524dD73a56D37bd0D0CaBce82c7f65c"; // replace with V1 contract address

  const HamsterCharacterNFTs = await ethers.getContractFactory(
    "HamsterCharacterNFTsV2"
  );
  console.log("Upgrading HamsterMarketPlace...");
  const upgradedHamsterCollection = await upgrades.upgradeProxy(
    hamsterCollectionV1Address,
    HamsterCharacterNFTs
  );

  console.log(
    "Hamster collection upgraded to:",
    upgradedHamsterCollection.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
