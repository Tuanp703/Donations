# Design Decisions
This file contains an overview of all design patterns used and decisions made during the development of these contracts.

## Decentralization and Autonomy
My design allows for the contract to operate autonomously and in a decentralized fashion. With exception of the emergency circuit breaker, the contract will handle beneficiary selection, donation collection, and payments to contract owner and beneficiary. I also implemented a self-destruct call which allows the contract to be terminated. This self-destruct is only accessible to the contract owner.

## Security Analysis
I submitted the Donations contract for a scan at [SmartCheck](https://tool.smartdec.net/scan/3339817f44684fa1bb82aa92e9805445). SmartCheck perfomed a static analysis for any possible vulnerabilities and other code issues that I may have missed. More information on SmartCheck can be found at https://github.com/smartdec/smartcheck

![SmartCheck](/docs/img/SmartCheck.PNG)

SmartCheck revealed only Severity Level 1 errors. Upon further review, I concluded that none of which requires additionall action.

## Spamming Prevention
The issue I noted with traditional ‘go fund me’ applications is that anyone can setup a funding request. As the result, many of these fundme projects just linger and never reach the raised amount, and utimately, end up abandoned. Accordingly they consume and waste valuable resources. By requiring a commitment fee of greater than 10% of the raised amount to be deposited at the start of the fundraising, this approach reduces spamming of the decentralized application similar to how gases are used on Ethereum network.

## Contract Inheritance
I implemented two contracts (contract FromParent and contract Donations). Contract FromParent initializes the contract owner and manages the payable public variables while contract Donations handles the core functions of the Dapps. The intent of this contract inheritance is to demonstrate contract extension.

## Fail Checks and Fails Early
For the smart contract functions, I put a list of requires at the top to specify the requirements for the successful completion of the functions. I also utilized modifiers to ensure that functions should only be executed by the correct callers and with appropriate state. This reduces unnecessary code execution and saves the caller gas.

## Safeguarding against Reentrancy
I incorporated Mutex lock as a primary safeguard against reentrancy attack. I also provided an owner control unlocking function for the lock to release the contract in case of an improbable inert situation.

Additionally, I also utilized checks-effects-interactions pattern by preventing both cross-function recursion call into the sendDonations function and withdrawDonations by checking the isAtLimit as a require check.

## Usage of SafeMath
I incorporated SafeMath functions (add, sub, div) from [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/math) into my contract as SafeMath library for usage in calculations to prevent any possible overflows and underflows. I chose to directly incorporate the library so that I can use the code for demonstration.

## Emergency Circuit Breaker
I implemented an emergency circuit breaker on the Donations contract which prevent the execution of the following activities when the emergency circuit is active:
a) Disable the selection of beneficiary (if one has not already been selected)
b) Disable submitting donations from donors to the contract.
c) Disables any withdrawn from the contract except that to be handled by the owner.
Emergency circuit breaker can only be triggered by the contract owner or the account[0] when you deploy the contract.

## Emergency Unlock
I utilized a Mutex to place a lock on the transfer of donations to the beneficiary and owner when the donation limit has been met. Additional information on Mutex implementation can be found at [https://medium.com/coinmonks/protect-your-solidity-smart-contracts-from-reentrancy-attacks-9972c3af7c21]
While it is improbably to accidently or manipulate the lock Boolean into an inert state, I also implemented an unlock toggle function controlled by the contract owner to release the lock in case of a locked state.