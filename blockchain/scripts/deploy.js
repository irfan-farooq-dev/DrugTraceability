async function main() {
  const [deployer] = await ethers.getSigners();

  const UsersContract = await ethers.getContractFactory("UsersContract");
  const users = await UsersContract.deploy();
  await users.deployed();

  const ProductsContract = await ethers.getContractFactory("ProductsContract");
  const products = await ProductsContract.deploy();
  await products.deployed();

  const SupplyChain = await ethers.getContractFactory("SupplyChain");
  const router = await SupplyChain.deploy(users.address, products.address);
  await router.deployed();

  console.log("UsersContract deployed to:", users.address);
  console.log("ProductsContract deployed to:", products.address);
  console.log("SupplyChain deployed to:", router.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
