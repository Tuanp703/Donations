pragma solidity ^0.5.0;

// Import key libraries for Ownable and SafeMath
// import "../installed_contracts/zeppelin/contracts/math/SafeMath.sol";
// import "installed_contracts/zeppelin/contracts/ownership/Ownable.sol";

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// This contract setup the owner.
// This contract provides inheritance to the main contract.
contract FromParent {
    address payable public owner;
    address payable public beneficiary = address(0);    // Set beneficiary to null

    constructor() public { // Set at start of deployment
        owner = msg.sender;             // Set the owner of contract
    }
}

// This is the Donations contract
// The contract does the following:
// 1. Initilizes the contract with a donation limit to be collected and a beneficiary. Similar to gofund me.
// 2. Users donate to the contract. Donation must be at least 1 ether.
// 3. Track donations until the donation limit has been reached, or terminate if at least 10% has been collected
// 4. Send 90% of the donations to the beneficiary
// 5. Owner gets 10% of the contract dopnation

// This contract inherits from the FromParent contract.
contract Donations is FromParent {
    using SafeMath for uint;

    mapping (address => uint) private balances;     // Track the donate amount from the user
    
    bool private hasBeneficiary = false;        // Set no beneficiary selected
	bool private isAtLimit = false;       // Set default for reaching donation limit flag
    bool private stopped = false;       // Set default circuit breaker/ emergency stop flag
	bool private lock = false;           // Safeguard against reentrancy
	
    string public emergencyTxt = 'Emergency circuit breaker is NOT ACTIVE';     // Track emergency circuit breaker status
    string public lockTxt = 'Lock is NOT ACTIVE';   // Track lock status
    
    uint public targetAmt;         // Track donation limit to be sought
	uint public donationAmt;        // Track current donation so far.
    uint public oldDonationAmt;    // Track donation amount before withdraw payout
    uint public oldBalance;         // Track the balance before withdraw payout
    uint public newBalance;         // Track the balance after withdraw payout

	uint private escrowAmt;         // Track the escrow amount from the beneficiary
	uint private beneficiaryAmt;    // Track the beneficiary amount from the total donations
	uint private ownerAmt;          // Track the owner amount from the total donations

    // Setup modifier for only owner 
    modifier isAdmin() {
        require(msg.sender == owner);
        _;
    }

    // Setup modifier for Beneficiary
    modifier hasNoBeneficiary() {
        require(hasBeneficiary == false, 'Beneficiary has already been setup.');
        _;
    }

    // Setup modifier for circuit breaker / Emergency stop flag to control control
    modifier notInEmergency {
        require(stopped == false, 'Emergency stop is active.');
        _;
    }
    
    // Setup modifier for circuit breaker / Emergency stop flag to control control
    modifier isInEmergency {
        require(stopped == true, 'Emergency stop is not active.');
        _;
    }
    
    // Returns the address of the Beneficiary
    event LogSetBeneficiary(
        address accountAddress
    );

    event LogRefresh(
        bool refresh
    );

   // The constructor set up default values for the contract
    constructor() public {
		targetAmt = 0;                      // Set donaiion target limit to zero
		donationAmt  = 0;				    // Set donation to zero
		isAtLimit = false;                  // Set donation flag as false
		lock = false;                       // Set default lock state as false
    }

    // Setup fallback to protect contract
    function() external payable {
		revert();
	}

    // This is a data view function and can be removed at completion.
    // function showIntValues() public view returns (uint, uint, uint, bool, bool, bool, bool) {
    //    return (address(this).balance, targetAmt, donationAmt, isAtLimit, lock, stopped, hasBeneficiary);
    // }

    // This function set the donation amount and the beneficiary
    // These actions can only be define by the owner
    // The beneficiary must commit to pay at least 10% of the proposed amount to be raised before the conbtract can accept the funding request
    function setDonationAndBeneficiary(uint _targetAmt) hasNoBeneficiary notInEmergency public payable returns (bool) {
        require(msg.sender != owner, 'Owner cannot be beneficiary.');   // Owner cannot be a beneficiary
        require(_targetAmt > 0, 'Donation limit must be greater than zero.');
        require(msg.value > _targetAmt.div(10), 'Escrow amount must be greater than 10% of the amount to be raised.');
        require(msg.value < _targetAmt, 'Escrow amount must be less than the amount to be raised.');
        
        hasBeneficiary = true;          // Accepts beneficiary for the contract and prevent recalling of the function
        escrowAmt = msg.value;          // Seup the escrow amount      
        targetAmt = _targetAmt;     // Setup the donation limit
        beneficiary = msg.sender;       // Setup the beneficiary
        oldDonationAmt = 0;             // Set to zero
        oldBalance = 0;             // Set to zero
        newBalance = address(this).balance;         // Update current contract balance

        // emit LogSetBeneficiary(beneficiary);
        // return (true);
    }

    // This is a random development function to be removed
    function setTestBeneficiary() public payable returns (bool) {
        beneficiary = msg.sender;
        newBalance = address(this).balance;
        emit LogRefresh(true);
    }    

    // This function accepts donations from Users
    function sendDonations() notInEmergency public payable returns (bool) {
        require(hasBeneficiary == true, 'Beneficiary has not been defined.');  // Donation must have a beneficiary
        require(isAtLimit == false, 'Donation limit has been reached.');    // Limit has not been reached
        require(msg.sender != owner, 'Owner cannot be a participant.');   // Owner cannot be a participant
        require(msg.sender != beneficiary, 'Beneficiary cannot be a participant.');   // Beneficiary cannot be a participant
		
		balances[msg.sender] = balances[msg.sender].add(msg.value);      // Track the donated amt from the user.
		donationAmt = donationAmt.add(msg.value);  // Track the current donations
        newBalance = address(this).balance;         // Update current contract balance
		
        // Check if donation limit has been reached
		if (donationAmt >= targetAmt) {
    		    isAtLimit = true;     // Set donation flag as having reach the target
                oldDonationAmt = donationAmt;   // Set the old donation amount - Use for testing
                oldBalance = address(this).balance;  // Set the before withdraw balance - Use for testing
    		    withdrawDonations();  // Call withdraw to faciliate payments.
    	} else {
    		    isAtLimit = false;     // Set donation flag as not having reach the target
    	}
		return (true);
    }

    // This function withdraws for the beneficiary and owner
    // Set global lock to prevent reentrancy
    // Compute payments to beneficiary and owner
    // Send to beneficiary and owner
    // implicitly set the transfer to prevent a reentrancy attack
    // Set payout flag to prevent reentrancy.    
    function withdrawDonations() notInEmergency public payable {
        require (isAtLimit == true, 'Has not reached donation limit.');     // must be at donation limit
        require(!lock);     // Must not already in locked state - This uses a MUTEX lock
        lock = true;        // Force locked state to prevent reenterancy
    
        ownerAmt = donationAmt.div(10);                     // Calculate the owner portion => 10%
        beneficiaryAmt = donationAmt.sub(ownerAmt);         // Calculate the beneficiary payment => 90%
        beneficiaryAmt = beneficiaryAmt.add(escrowAmt);     // Calculate the beneficiary payment adjusted for escrow payment
        
        beneficiary.transfer(beneficiaryAmt);       // Transfer the beneficiary amount to beneficiary
        owner.transfer(ownerAmt);                   // Transfer the owner amount to owner
        newBalance = address(this).balance;  // Set the after withddraw balance - Use for testing
        
        lock = false;               // Clear Locked state
        hasBeneficiary = false;     // Wait for new beneficiary        
        donationAmt = 0;            // Clear to zero and waits for new beneficiary
        targetAmt = 0;              // Clear to zero and waits for new beneficiary
        beneficiaryAmt = 0;         // Set to zero
        ownerAmt = 0;               // Set to zero
        isAtLimit = false;          // Set to false
        beneficiary = address(0);   // Clear beneficiary
    } 

    // Add function that restricts stopping a contract to be based on another action
    function toggleContractActive() isAdmin public {
        stopped = !stopped;     // Set the cirbuit breaker switch
        if (stopped) {
            emergencyTxt = 'Emergency circuit breaker is ACTIVE';
        } else {
            emergencyTxt = 'Emergency circuit breaker is NOT ACTIVE';
        }
    }

    // This function unlocks the lock for withdraws, just in case the contract is bugged
    function unlockLock() isAdmin isInEmergency public payable {
        lock = !lock;            // Set the lock
        if (lock) {
            lockTxt = 'Lock is ACTIVE';
        } else {
            lockTxt = 'Lock is NOT ACTIVE';
        }        
    }

    // This function ends collections and send contract value to owner
    function endDonations() isAdmin isInEmergency public payable {
        selfdestruct(owner);    // End contract and send any remaining funds to owner
    }

}
