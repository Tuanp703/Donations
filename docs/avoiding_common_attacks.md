# Avoiding Common Attacks
This file contains an overview of the measures I have taken to secure these contracts against common attacks.

## Safeguarding against Reentrancy
I incorporated a Mutex lock as a primary safeguard against reentrancy attack. I also provided an owner control unlocking function for the lock to release the contract in case of an improbable inert situation.

Additionally, I also utilized checks-effects-interactions pattern by preventing both cross-function recursion call into the sendDonations function and withdrawDonations by checking the isAtLimit as a require check.

## Usage of SafeMath
I incorporated SafeMath functions (add, sub, div) from [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/math) into my contract as SafeMath library for usage in calculations to prevent any possible overflows and underflows. I chose to directly incorporate the library so that I can use the code for demonstration.

## Inefficient Usage of Resources and Preventing Attempts to Consume Resources
Resources on a public blockchain are expensive to maintain. Accordingly, we do not want people to setup many fundraising events without having a reasonable chance of attaining the prescribed goal. The process of requiring an escrow of 10% of the planned fundraising amount from the beneficiary reduces chances of possible abuse or spam of the dApp. In many ways this approach is similar to how gas are needed to run transactions on Ethereum blockchain.
