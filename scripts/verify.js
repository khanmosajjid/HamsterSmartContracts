const { ethers } = require("hardhat");

async function main() {
  const contractAddress = "0xC65332247705500d6bFC1c44344571d9db430C68"; // replace with your deployed contract address
  await hre.run("verify:verify", {
    address: contractAddress,
    constructorArguments: [], // Since this is a proxy, there might not be any args to verify.
  });
  console.log("verified contract")
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
