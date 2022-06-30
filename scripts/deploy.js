async function main() {
    const Wallet = await ethers.getContractFactory("multiPartyWallet");
    const wallet = await Wallet.deploy();
  
    await wallet.deployed();
  
    console.log("multi-party wallet deployed to:", greeter.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });