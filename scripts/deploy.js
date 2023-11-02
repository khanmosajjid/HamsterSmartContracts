const { ethers, upgrades } = require("hardhat");

async function main() {
  const HamsterMarketPlace = await ethers.getContractFactory(
    "HamsterMarketPlaceV1"
  );
  const validNFTContracts = ["0x14d9a6637Ef55FFd0301048FB57199439c84fb62"]; // list of valid NFT contracts
  const commissionAddress = "0x4AE8356dF675d7A4c3Ab3C3fA4E9e458fcbAf7Ff"; // replace with your address
  const hamsterMarket = await upgrades.deployProxy(HamsterMarketPlace, [
    validNFTContracts,
    commissionAddress,
  ]);

  console.log("HamsterMarketPlace deployed to:", hamsterMarket.address);
  const contractAddress = hamsterMarket.address; // replace with your deployed contract address

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
