// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This line imports the ERC20.sol file from the OpenZeppelin library, 
// which contains the implementation of the ERC20 token standard.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
 
// This line defines a new Solidity contract named MyToken, which inherits from the ERC20 contract. 
// This means that MyToken will have all the functionalities of an ERC20 token.
contract MyToken is ERC20 {

// Maps addresses to the amount of tokens staked by each address. 
// It is declared as public, meaning it can be read directly from outside the contract.
    mapping(address => uint) public staked;

// Maps addresses to a timestamp indicating when the tokens were staked. 
// It is declared as private, meaning it can only be accessed internally within the contract.
    mapping(address => uint) private stakedFromTS;

// This is the constructor function of the MyToken contract.
// It is called only once when the contract is deployed.
// It calls the constructor of the ERC20 contract with the parameters 
// "MyToken" (name) and "MTK" (symbol) to initialize the token.
    constructor() ERC20("MyToken", "MEG") {

// It mints 1000 tokens and assigns them to the address that deployed the contract (msg.sender).
        _mint(msg.sender, 10 ** 18);
    }

 // This function allows users to stake tokens.
    function stake(uint amount) external {

// It takes an amount parameter indicating the number of tokens to stake.
        require(amount > 0, "amount is <= 0");

// It checks that the amount is greater than zero 
// and that the user's balance is sufficient to cover the stake.
        require(balanceOf(msg.sender) >= amount, "balance is <= amount");

// It transfers the specified amount of tokens from the user's address to the contract's address
// using the _transfer function inherited from ERC20.
        _transfer(msg.sender, address(this), amount);
 
// This conditional block checks if the user had previously staked tokens. 
// If they did, it calls the claim function.
        if (staked[msg.sender] > 0) {
            claim();
        }

// These lines update the timestamp for when the user last staked tokens 
// and increase the amount of tokens staked by the user.
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

// This function allows users to unstake tokens.
    function unstake(uint amount) external {

// It takes an amount parameter indicating the number of tokens to unstake.
        require(amount > 0, "amount is <= 0");

// It checks that the amount is greater than zero and that the user has previously staked tokens.
        require(staked[msg.sender] > 0, "You did not stake with us");

// It updates the timestamp for when the user last staked tokens
        stakedFromTS[msg.sender] = block.timestamp;

//  decreases the amount of tokens staked by the user
        staked[msg.sender] -= amount;

// transfers the specified amount of tokens from the contract's address back to
// the user's address using the _transfer function inherited from ERC20.
        _transfer(address(this), msg.sender, amount);
    }

// This function allows users to claim rewards for their staked tokens.
    function claim() public {

// It checks that the user has staked tokens.
        require(staked[msg.sender] > 0, "Staked is <= 0 ");

// It calculates the number of seconds the tokens have been staked.
        uint secondsStaked = block.timestamp - stakedFromTS[msg.sender];

// It calculates the rewards based on the number of tokens staked 
// and the duration they have been staked (assuming a year has 3.154e7 seconds).
        uint rewards = staked[msg.sender] * secondsStaked / 3.154e7;

// It mints the calculated rewards and assigns them to the user's address.
        _mint(msg.sender, rewards);

// It updates the timestamp for when the user last claimed rewards.
        stakedFromTS[msg.sender] = block.timestamp;
    }
}
