pragma solidity ^0.4.22;

// File: contracts/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/BettingGame.sol

contract BettingGame {
    
    address public owner;
    
    struct Bet {
        uint256 choice;
        uint256 amount;
        bool paid;
        bool initialized;
    }
    mapping(address => Bet) bets;

    using SafeMath for uint256;
    
    uint256 total_bet_amount;
    mapping(uint256 => uint256) choice_bet_amounts;
    
    uint256 correct_choice;

    uint256 game_status; // 0 not started; 1 running; 2 ended
    
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
    
    constructor () public {
        owner = msg.sender;
        game_status = 0;
    }
    
    function startGame() external onlyOwner {    
        total_bet_amount = 0;
        game_status = 1;
    }
    
    function placeBet (uint256 _choice) public payable {
        require (game_status == 1); // game is running
        require (_choice > 0);
        require (_choice <= 12);
        require (msg.value > 0); // Must have bet amount
        require (bets[msg.sender].initialized == false); // Cannot bet twice
        
        Bet memory newBet = Bet(_choice, msg.value, false, true);
        bets[msg.sender] = newBet;
        
        choice_bet_amounts[_choice] = choice_bet_amounts[_choice] + msg.value;
        total_bet_amount = total_bet_amount + msg.value;
    }
    
    function endGame(uint256 _correct_choice) external onlyOwner {
        correct_choice = _correct_choice;
        game_status = 2;
    }
    
    function payMe () public {
        require (game_status == 2); // game is done
        require (bets[msg.sender].initialized); // Must have a bet
        require (bets[msg.sender].amount > 0); // More than zero
        require (bets[msg.sender].choice == correct_choice); // chose correctly
        require (bets[msg.sender].paid == false); // chose correctly
        
        uint256 payout = bets[msg.sender].amount * total_bet_amount / choice_bet_amounts[correct_choice];
        if (payout > 0) {
            msg.sender.transfer(uint256(payout));
            bets[msg.sender].paid == true; // cannot claim twice
        }
    }

    function getAnswer() public view returns (uint256) {
        return (correct_choice);
    }
  
    function terminate() external onlyOwner {
        selfdestruct(owner);
    }
}
