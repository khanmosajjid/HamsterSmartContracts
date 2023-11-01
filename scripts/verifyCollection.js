const { ethers } = require("hardhat");

async function main() {
     const rare = [1, 2, 3, 4, 5];
     const ultraRare = [7, 8, 9];
     const baseURI =
       "https://ice-vanilla-ham-nfts.s3.us-east-2.amazonaws.com/vanilla-ice-character-json/";
     const payable_address = "0x4AE8356dF675d7A4c3Ab3C3fA4E9e458fcbAf7Ff";
  const contractAddress = "0x2c96fD456524dD73a56D37bd0D0CaBce82c7f65c"; // replace with your deployed contract address
  await hre.run("verify:verify", {
    address: contractAddress,
    constructorArguments: [], // Since this is a proxy, there might not be any args to verify.
  });
  console.log("verified successfully")
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
