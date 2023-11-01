const { ethers } = require("hardhat");

async function main() {
  const contractAddress = "0xE34E26DcF6F979daEd68815914440A8D1ACc2d08"; // replace with your deployed contract address
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
