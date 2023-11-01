const { ethers, upgrades } = require("hardhat");

async function main() {
  const HamsterMarketPlace = await ethers.getContractFactory(
    "HamsterMarketPlaceV1"
  );
  const validNFTContracts = ["0x2c96fD456524dD73a56D37bd0D0CaBce82c7f65c"]; // list of valid NFT contracts
  const commissionAddress = "0x4AE8356dF675d7A4c3Ab3C3fA4E9e458fcbAf7Ff"; // replace with your address
  const hamsterMarket = await upgrades.deployProxy(
    HamsterMarketPlace,
    [validNFTContracts, commissionAddress],
  
  );

  console.log("HamsterMarketPlace deployed to:", hamsterMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
