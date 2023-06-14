var contractHTLC721 = artifacts.require("HTLC721");
var contractNFTA = artifacts.require("NFTA");
var contractNFTB = artifacts.require("NFTB");

// default case is enough: setting the first account as admin
module.exports = function(deployer, network){
    deployer.deploy(contractHTLC721)
    deployer.deploy(contractNFTA)
    deployer.deploy(contractNFTB)
}