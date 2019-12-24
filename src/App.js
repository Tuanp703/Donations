// This uses async / await
App = {
        loading: false,
        contracts: {},
  
    load: async () => {
        await App.loadWeb3()
        await App.loadAccount()
        await App.loadContract()
        await App.render()
    },
  
    // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
    loadWeb3: async () => {
        if (typeof web3 !== 'undefined') {
            App.web3Provider = web3.currentProvider
            web3 = new Web3(web3.currentProvider)
        } else {
            window.alert("Please connect to Metamask.")
        }
        // Modern dapp browsers...
        if (window.ethereum) {
            window.web3 = new Web3(ethereum)
            try {
            // Request account access if needed
            await ethereum.enable()
            // Acccounts now exposed
            web3.eth.sendTransaction({/* ... */})
            } catch (error) {
            // User denied account access...
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = web3.currentProvider
            window.web3 = new Web3(web3.currentProvider)
            // Acccounts always exposed
            web3.eth.sendTransaction({/* ... */})
        }
        // Non-dapp browsers...
        else {
            console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
    },
  
    loadAccount: async () => {
        // Set the current blockchain account selected in Metamask
        // Display this account address on the dapp.
        App.account = web3.eth.accounts[0]
        console.log(App.account)
    },
  
    loadContract: async () => {
        // Create a JavaScript version of the smart contract
        const donations = await $.getJSON('Donations.json')
        console.log(donations)
        App.contracts.Donations = TruffleContract(donations)
        App.contracts.Donations.setProvider(App.web3Provider)
    
        // Hydrate the smart contract with values from the blockchain
        App.donations = await App.contracts.Donations.deployed()
    },
  
    render: async () => {
        // Prevent double render
        if (App.loading) {
            return
      }
  
        // Update app loading state
        App.setLoading(true)
  
        // Render Active Metamask Account
        $('#account').html(App.account)
    
        // Render Tasks
        await App.renderTask1()
        await App.renderTask2()
        await App.renderTask3()
        await App.renderTask4()
        await App.renderTask5()
        await App.renderTask6()
        await App.renderTask7()
        await App.renderTask8()

        // Update loading state
        App.setLoading(false)
    },
  
    //renderTasks: 
    renderTask1: async () => {
        // Load the beneficiary address
        beneficiary = await App.donations.beneficiary()
        console.log('show beneficiary')
        console.log (beneficiary)
        $('#beneficiary').html(beneficiary)
    },    

    renderTask2: async () => {
        // Load the donations collected to date
        donationAmt = await App.donations.donationAmt()
        donationAmtEth = web3.fromWei(donationAmt, 'ether').toNumber()
        console.log('show donationAmt')
        console.log (donationAmt.toNumber())
        $('#donationAmtEth').html(donationAmtEth)
    },     

    renderTask3: async () => {
        // Load the owner address
        owner = await App.donations.owner()
        console.log('show owner')
        console.log (owner)
        $('#owner').html(owner)  
    }, 

    renderTask4: async () => {
        // Load the current contract balance
        newBalance = await App.donations.newBalance()
        newBalanceEth = web3.fromWei(newBalance, 'ether').toNumber()
        console.log('show contract balance')
        console.log (newBalance)
        $('#newBalance').html(newBalanceEth)
    },     

    renderTask5: async () => {
        // Load the current donation limit
        targetAmt = await App.donations.targetAmt()
        targetAmtEth = web3.fromWei(targetAmt, 'ether').toNumber()
        console.log('show donation limit')
        console.log(targetAmt)
        $('#donationMax').html(targetAmtEth)
    }, 
    
    renderTask6: async () => {
        // Load the donations collected to date
        donationAmt = await App.donations.donationAmt()
        console.log('show donationAmt')
        console.log (donationAmt.toNumber())
        $('#donationAmt').html(donationAmt.toNumber())
    },     

    renderTask7: async () => {
        // Load emergency circuit text
        emergency = await App.donations.emergencyTxt()
        console.log (emergency)
        $('#emergency').html(emergency)
    },

    renderTask8: async () => {
        // Load emergency circuit text
        lock = await App.donations.lockTxt()
        console.log (lock)
        $('#lock').html(lock)
    },

    // Set the beneficiary for the smarty contract
    bookBeneficiary: async () => {
        App.setLoading(true)
        donationLimit = $('#donationLimit').val()
        escrow = $('#escrow').val()

        // This try-catch evals the promise
        try {
            await App.donations.setDonationAndBeneficiary(donationLimit, { from:web3.eth.accounts[0], value: escrow }) 
        } catch (e) {
                // If the promise results in an error, force a browser refresh
                window.location.reload()
            return true;
        }
        window.location.reload()
    }, 

    // Accept donation from a donor
    makeDonation: async () => {
        App.setLoading(true)
        const donation = $('#donation').val()

        // This try-catch evals the promise
        try {
            await App.donations.sendDonations({ from:web3.eth.accounts[0], value: donation })
        } catch (e) {
                // If the promise results in an error, force a browser refresh
                window.location.reload()
            return true;
        }
        window.location.reload()
    }, 

    // Turn ON/OFF emergency circuit
    setEmergencyOnOff: async () => {
        App.setLoading(true)

        // This try-catch evals the promise
        try {
            await App.donations.toggleContractActive()
        } catch (e) {
                // If the promise results in an error, force a browser refresh
                window.location.reload()
            return true;
        }
        window.location.reload()
    }, 

    // Turn ON/OFF emergency circuit
    setUnlockOnOff: async () => {
        App.setLoading(true)

        // This try-catch evals the promise
        try {
            await App.donations.unlockLock()
        } catch (e) {
                // If the promise results in an error, force a browser refresh
                window.location.reload()
            return true;
        }
        window.location.reload()  
    }, 

    setLoading: (boolean) => {
      App.loading = boolean
      const loader = $('#loader')
      const purpose = $('#purpose')
      const content = $('#content')
      if (boolean) {
        loader.show()
        purpose.hide()
        content.hide()
      } else {
        loader.hide()
        purpose.show()
        content.show()
      }
    }
  }
  
  $(() => {
    $(window).load(() => {
      App.load()
    })
  })