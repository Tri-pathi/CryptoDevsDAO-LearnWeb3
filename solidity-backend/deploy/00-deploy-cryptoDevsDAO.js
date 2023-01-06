const { network } = require("hardhat");
const { CryptoDevsNFTContractAddress } = require("../constant");

module.exports=async({deployments,getNamedAccounts})=>{
 const{deploy,log}=deployments;
 const {deployer}=await getNamedAccounts();


 const fakeNFTMarketplace=await deploy("FakeNFTMarketplace",{
    from: deployer,
    log:true,
    args:[],
    waitConfirmations:network.config.waitConfirmations||1

 })
 log(`FakeNFTMarketplace Contract is deployed at ${fakeNFTMarketplace.address}`);

 

 const cryptoDevsDAO=await deploy("CryptoDevsDAO",{
    from: deployer,
    log:true,
    args:[CryptoDevsNFTContractAddress,fakeNFTMarketplace.address],
    waitConfirmations:network.config.waitConfirmations||1

 })
 log(`CryptoDevsDAO Contract is deployed at ${cryptoDevsDAO.address}`);


 console.log("*............................*");
 console.log("Cool.. Now we are ready for frontend interactions");
}

//FakeNFTMarketplace Address=0xf16A147db206f76f25Bf3333836D69b5378929A0


//CryptoDevsDAO Address=0x6BC7E0eC5C26B2517c58e158b6f789Bc4B8a5Aa7
