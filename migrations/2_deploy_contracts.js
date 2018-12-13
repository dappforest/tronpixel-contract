const Migrations = artifacts.require("./Migrations.sol")
const TronPixel = artifacts.require("./TronPixel.sol")

module.exports = function(deployer) {
  deployer.deploy(Migrations)
  deployer.deploy(TronPixel)
}