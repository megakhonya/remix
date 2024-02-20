// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// An interface for an ERC20 token, defining the transfer and transferFrom functions.
interface IERC20 {

// The transfer function is used to send tokens from one address to another
    function transfer(address, uint) external returns (bool);
 
// The transferFrom function is used to transfer tokens on behalf of a specific address.
    function transferFrom(address, address, uint) external returns (bool);
}
 
// Defines the start of the CrowdFund contract.
contract CrowdFund {

// This is an event declaration for when a crowdfunding campaign is launched.
    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );

// This is an event that is emitted when a campaign is canceled.
    event Cancel(uint id);

// This is an event that is emitted when a user pledges to a campaign.
    event Pledge(uint indexed id, address indexed caller, uint amount);

// This is an event that is emitted when a user unpledges from a campaign.
    event Unpledge(uint indexed id, address indexed caller, uint amount);

// This is an event that is emitted when the campaign creator claims the funds after the campaign is successfully completed.
    event Claim(uint id);

// This is an event that is emitted when a user refunds their pledge after the campaign is canceled or not successfully completed.
    event Refund(uint id, address indexed caller, uint amount);
 
// Defines a Campaign struct that represents a crowdfunding campaign
    struct Campaign {

// Creator of campaign
        address creator;

// Amount of tokens to raise
        uint goal;

// Total amount pledged
        uint pledged;

// Timestamp of start of campaign
        uint32 startAt;

// Timestamp of end of campaign
        uint32 endAt;

// True if goal was reached and creator has claimed the tokens.
        bool claimed;
    }
 
// Declares a public state variable named token of type IERC20,
// It is marked as immutable, meaning its value cannot be changed after the contract's construction,
// It represents the ERC20 token contract that will be used for the crowdfunding campaign.
    IERC20 public immutable token;

//  This line declares a public state variable called count.
// It keeps track of the total number of campaigns launched.
    uint public count;

//  This is a public mapping that stores the campaign details. 
// The key is the campaign ID, and the value is a Campaign struct.
    mapping(uint => Campaign) public campaigns;

// This is a public mapping that stores the amount pledged by each user for each campaign. 
// The first key is the campaign ID, the second key is the user address, and the value is the amount pledged.
    mapping(uint => mapping(address => uint)) public pledgedAmount;

//  It takes an ERC20 token address as an argument. The token address is stored in the token variable.
    constructor(address _token) {
        token = IERC20(_token);
    }

// This is  used to launch a new campaign. 
// It takes the campaign goal, start time, and end time as arguments.
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {

// This line checks if the start time is greater than or equal to the current block timestamp. 
// If not, it throws an error.
        require(_startAt >= block.timestamp, "start at < now");

// This line checks if the end time is greater than or equal to the start time.
// If not, it throws an error.
        require(_endAt >= _startAt, "end at < start at");

// This line checks if the end time is less than or equal to the current block timestamp plus 90 days.
// If not, it throws an error.
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

// This line increments the total number of campaigns by 1.
        count += 1;

// Creates a new campaign struct and stores it in the campaigns mapping with the campaign ID as the key.
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

// This line emits the Launch event with the campaign ID, creator address, goal, start time, and end time.
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

// It is used to cancel a campaign. It takes the campaign ID as an argument.
    function cancel(uint _id) external {

// This line retrieves the campaign details using the campaign ID.
        Campaign memory campaign = campaigns[_id];

// Checks if the user who is trying to cancel the campaign is the creator of the campaign. 
// If not, it throws an error.
        require(campaign.creator == msg.sender, "not creator");

// Checks if the campaign has not started yet.
//  If it has started, it throws an error.
        require(block.timestamp < campaign.startAt, "started");
 
//  This line deletes the campaign from the campaigns mapping.
        delete campaigns[_id];

// This line emits the Cancel event with the campaign ID.
        emit Cancel(_id);
    }
 
// This is used to pledge to a campaign. It takes the campaign ID and the amount to pledge as arguments.
    function pledge(uint _id, uint _amount) external {

//  It requires the campaign ID _id to be valid and not exceeding the total count of campaigns. 
        Campaign storage campaign = campaigns[_id];

//  This line checks if the campaign has started.
        require(block.timestamp >= campaign.startAt, "not started");

// This line checks if the campaign has not ended yet.
        require(block.timestamp <= campaign.endAt, "ended");
 
// This line increments the pledged variable of the campaign struct by the amount pledged.
        campaign.pledged += _amount;

// This line increments the amount pledged by the user for this campaign in the `pledged
        pledgedAmount[_id][msg.sender] += _amount;
        
//  It transfers _amount tokens from the caller's address to the contract's address
        token.transferFrom(msg.sender, address(this), _amount);

 // It emits a Pledge event to notify external parties about the pledge.
        emit Pledge(_id, msg.sender, _amount);
    }
 
//  Allows a pledger to unpledge a certain amount of tokens from a campaign before it starts.
    function unpledge(uint _id, uint _amount) external {

// Ensures that the campaign ID is valid
        Campaign storage campaign = campaigns[_id];

// Ensures the campaign has not started yet, and it has not been claimed
        require(block.timestamp <= campaign.endAt, "ended");
 
 // Reduces the pledged amount by _amount for the caller's address in the pledgedAmount mapping
        campaign.pledged -= _amount;

//  Updates the total pledged amount for the campaign. 
        pledgedAmount[_id][msg.sender] -= _amount;

// It transfers _amount tokens from the contract's address back to the caller's address
        token.transfer(msg.sender, _amount);
 
// It emits an Unpledge event to notify external parties about the unpledge.
        emit Unpledge(_id, msg.sender, _amount);
    }
 
//  Allows the campaign creator to claim the pledged tokens after the campaign has ended.
    function claim(uint _id) external {

// It requires the campaign ID _id to be valid
        Campaign storage campaign = campaigns[_id];

//  It requires the caller to be the creator of the campaign, 
        require(campaign.creator == msg.sender, "not creator");

// It requires the campaign to have ended,
        require(block.timestamp > campaign.endAt, "not ended");

// It requires  the campaign goal to be reached,
        require(campaign.pledged >= campaign.goal, "pledged < goal");

// It requires the campaign not to have been claimed yet.
        require(!campaign.claimed, "claimed");
 
// If all conditions are met, it marks the campaign as claimed, 
        campaign.claimed = true;

// Transfers the goal amount of tokens from the contract's address to the caller's address,
        token.transfer(campaign.creator, campaign.pledged);
 
// Emits a Claim event to notify external parties about the successful claim.
        emit Claim(_id);
    }
 
 // This function allows users to request a refund of their pledged tokens
    function refund(uint _id) external {

// It requires the campaign ID _id to be valid
        Campaign memory campaign = campaigns[_id];

//  It requires that the campaign's end time has passed
        require(block.timestamp > campaign.endAt, "not ended");

// The funding goal has not been reached, and the user has pledged some tokens
        require(campaign.pledged < campaign.goal, "pledged >= goal");
 
 // If the requirements are met, it retrieves the pledged amount for the sender,
        uint bal = pledgedAmount[_id][msg.sender];

// Sets it to 0 in the pledgedAmount mapping,
        pledgedAmount[_id][msg.sender] = 0;

// Transfers the refund amount of tokens back to the caller
        token.transfer(msg.sender, bal);
 
 // It emits a Refund event to notify external parties about the successful refund
        emit Refund(_id, msg.sender, bal);
    }
}