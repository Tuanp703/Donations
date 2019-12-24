/*

The public version of the file used for testing can be found here: https://gist.github.com/ConsenSys-Academy/ce47850a8e2cba6ef366625b665c7fba

This test file has been updated for Truffle version 5.0. If your tests are failing, make sure that you are
using Truffle version 5.0. You can check this by running "trufffle version"  in the terminal. If version 5 is not
installed, you can uninstall the existing version with `npm uninstall -g truffle` and install the latest version (5.0)
with `npm install -g truffle`.

*/
let catchRevert = require("./exceptionsHelpers.js").catchRevert
var Donations = artifacts.require("./Donations.sol")

contract('Donations', function(accounts) {

  // This section setup core testing variables such as accounts[0], [1] etc. along with default values
  const owner = accounts[0]             // the owner
  const beneficiary1 = accounts[1]       // The beneficiary
  const targetAmt1 = 2000000000000000   // Set initial donation limit (test at 0.0002 ethers)
  const escrowAmt1 = targetAmt1 * 0.1 + 1  // Set escrow amount of at least 10% of test donation + 1
  const escrowAmt2 = targetAmt1 - 1     // Set escrow amount of at least 10% of test donation but less than the donation limit

  const donor1 = accounts[2]   // The donor1 to test donor can donate
  const donationAmt1 = 213345 // Some amount of wei

  const donor2 = accounts[3]   // The donor2 to test donation limit
  const donationAmt2 = targetAmt1 // Set donation amount that meets donation limit

  beforeEach(async () => {
    instance = await Donations.new()
  })

  // This testing portion evaluates the constructor initialization
  describe("Setup", async() => {
    // Test to make sure that the owner is set at the initial deployment of the contract
    it("Has an owner as the deployer of the contract", async () => {
      var t_owner = await instance.owner.call()
      var deployer = accounts[0]
      assert.equal(t_owner, deployer, 'The owner was not set as the deployer')
    });
  })

  // This testing portion evaluates the core functions of the contract
  describe("Functions", () => {
    // This test evaluates that a beneficiary has been setup and that the beneficiary sends at least the required escrow amount.
    it("Has a beneficiary and the correct minimum escrow for the donation limit", async () => {
      var beneficiary = beneficiary1
      var targetAmt = targetAmt1
      var escrowAmt = escrowAmt1

      await instance.setDonationAndBeneficiary(targetAmt, {from: beneficiary1, value: String(escrowAmt)})
      var t_beneficiary = await instance.beneficiary.call();
      assert.equal(t_beneficiary, beneficiary, 'beneficiary or minimum escrow for the donation limit was not properly set')
    });

    // This test evaluates that a beneficiary has been setup and that the beneficiary did not send the donation target or more.
    it("Has a beneficiary and the correct maximum escrow for the donation limit", async () => {
      var beneficiary = beneficiary1
      var targetAmt = targetAmt1
      var escrowAmt = escrowAmt2

      await instance.setDonationAndBeneficiary(targetAmt, {from: beneficiary1, value: String(escrowAmt)})
      var t_beneficiary = await instance.beneficiary.call();
      assert.equal(t_beneficiary, beneficiary, 'beneficiary or maximum escrow for the donation limit was not properly set')
    });  

    // This test checks that a donor can donate without restriction.
    it("Donor is able to donate", async() =>{
      var beneficiary = beneficiary1
      var targetAmt = targetAmt1
      var escrowAmt = escrowAmt1  
      var donor = donor1
      var donorAmt = donationAmt1
   
      await instance.setDonationAndBeneficiary(targetAmt, {from: beneficiary1, value: String(escrowAmt)})
      await instance.sendDonations({from: donor, value: String(donorAmt)})
      var t_donationAmt = await instance.donationAmt.call();
      assert.equal(t_donationAmt, donorAmt, 'Donation performs successfully')
    });

    // This test checks when the donation limit has been met.
    it("Donor donates at least the donation limit", async() =>{
      var beneficiary = beneficiary1
      var targetAmt = targetAmt1
      var escrowAmt = escrowAmt1  
      var donor = donor2
      var donorAmt = donationAmt2
   
      await instance.setDonationAndBeneficiary(targetAmt, {from: beneficiary1, value: String(escrowAmt)})
      await instance.sendDonations({from: donor, value: String(donorAmt)})
      var t_donationAmt = await instance.oldDonationAmt.call();
      assert.equal(t_donationAmt.toString(), donorAmt.toString(), 'Donation target is met successfully')
    });

    // This test checks to make sure the correct transfer was made to owner and beneficiary.
    it("Transfer the correct amount to owner and beneficiary", async() =>{
      var beneficiary = beneficiary1
      var targetAmt = targetAmt1
      var escrowAmt = escrowAmt1  
      var donor = donor2
      var donorAmt = donationAmt2
   
      await instance.setDonationAndBeneficiary(targetAmt, {from: beneficiary1, value: String(escrowAmt)})
      await instance.sendDonations({from: donor, value: String(donorAmt)})
      var t_donationAmt = await instance.oldDonationAmt.call();
      var t_oldBalance = await instance.oldBalance.call();
      var t_newBalance = await instance.newBalance.call();

      // The difference after transfer must be zero based on sum of donations + any escrow amount
      var t_diff = t_oldBalance - t_donationAmt - escrowAmt
      assert.equal(t_diff.toString(),t_newBalance.toString(), 'Donation transfer successfully')
    });
  })

})
