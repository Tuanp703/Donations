var donations = artifacts.require("./Donations.sol");

module.exports = function(deployer) {
  deployer.deploy(donations);
};
