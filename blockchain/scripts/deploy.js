async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const SupplyChain = await ethers.getContractFactory("SupplyChain");
  const contract = await SupplyChain.deploy("Test Manufacturer", "irfanf33@gmail.com");

  await contract.deployed();
  console.log("Contract deployed at:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});