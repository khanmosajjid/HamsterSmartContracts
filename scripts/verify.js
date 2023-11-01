const { ethers } = require("hardhat");

async function main() {
  const contractAddress = "0x1e443f67005984111496f6cce2ca96744a5fbfe9"; // replace with your deployed contract address
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
