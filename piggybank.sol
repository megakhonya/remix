// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract JumboJunior {
    event Deposit (uint amount);
    event Withdraw (uint amount);
    address public owner = msg.sender;

//FALL-BACK FUNCTION
    receive () external payable {
        
        emit Deposit (msg.value);

    }

    function transfer () public {
        require (msg.sender == owner, "You are the owner");
        emit Withdraw (address (this).balance);
        selfdestruct(payable(msg.sender));
    }
}