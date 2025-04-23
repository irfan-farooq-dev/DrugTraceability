async function main() {
  const [sender] = await ethers.getSigners();

  const tx = await sender.sendTransaction({
    to: "0x9187cA97aA9A6A93a979D9745f6A0C45154FD7A7",
    value: ethers.utils.parseEther("1.0"),
  });

  console.log("Transaction hash:", tx.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
