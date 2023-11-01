// scripts/deploy.js

const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const HamsterCharacterNFTs = await ethers.getContractFactory(
    "HamsterCharacterNFTs"
  );

  const rare = [1, 2, 3, 4, 5];
  const ultraRare = [7, 8, 9];
  const baseURI =
    "https://ice-vanilla-ham-nfts.s3.us-east-2.amazonaws.com/vanilla-ice-character-json/";
  const payable_address = "0x4AE8356dF675d7A4c3Ab3C3fA4E9e458fcbAf7Ff";

  const tx = await upgrades.deployProxy(HamsterCharacterNFTs, [
    rare,
    ultraRare,
    baseURI,
    payable_address,
  ]);
  await tx.deployed();

  console.log("HamsterCharacterNFTs deployed to:", tx.address);
  const contractAddress = tx.address; // replace with your deployed contract address
  await hre.run("verify:verify", {
    address: contractAddress,
    constructorArguments: [], // Since this is a proxy, there might not be any args to verify.
  });
  console.log("verified contract");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
