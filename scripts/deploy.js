const main = async () => {
    const gameContractfactory = await hre.ethers.getContractFactory('MyNFTGame');
    const gameContract = await gameContractfactory.deploy(    
    ["MARIO", "LUIGI", "PRINCESS PEACH"],       // Names
    ["https://i.imgur.com/fHnyMAX.png", // Images
    "https://i.imgur.com/p78xG4Y.png", 
    "https://i.imgur.com/aHbpk1n.png"],
    [100, 200, 300],                    // HP values
    [100, 50, 25],
    'Master Chief',
    "https://i.imgur.com/7MdQmMx.png",
    1000,
    50);
    await gameContract.deployed();
    console.log(`contract deployed to - ${gameContract.address}`)
    let txn;
    txn = await gameContract.mintCharacter(1)
    await txn.wait();
    // Get the value of the NFT's URI.
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri);
    txn = await gameContract.attackBoss();
await txn.wait();
txn = await gameContract.attackBoss();
await txn.wait();
}
const runMain = async () => {
    try {
        await main();
        process.exit(0);
    }
    catch(error) {
        console.log(error);
        process.exit(1);
    }
}
runMain()