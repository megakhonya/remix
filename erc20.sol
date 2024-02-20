// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "interface.sol";

contract ERC20 is IERC20 {

  uint public override totalSupply;

  mapping(address => uint) public override balanceOf;

  mapping(address => mapping(address => uint)) public override allowance;

   string public name ="MEG TOKEN";
   string public symbol ="MMA";
   uint public decimal = 18;

   function transfer(address recepient, uint amount)
   external override returns(bool) {
      balanceOf[msg.sender] -= amount;
      balanceOf[recepient] += amount;
emit Transfer(msg.sender,recepient,amount);
 return true;
}

function approve(address spender,uint amount)
external override returns(bool){
allowance[msg.sender][spender] = amount;
emit Approval(msg.sender,spender,amount);
return true;
}
 
function transferFrom(address sender,address recepient,uint amount)
external override returns(bool){
allowance[sender][msg.sender] -= amount;
 balanceOf[sender] -= amount;
  //balanceOf[sender] =  balanceOf[sender] - amount;
 balanceOf[recepient] += amount;
 emit Transfer(sender, recepient, amount);
return true;
}
 
function mint(uint amount) external {
balanceOf[msg.sender] += amount;
totalSupply += amount;
emit Transfer(address(0), msg.sender, amount);
}
 
function burn(uint amount) external {
   balanceOf[msg.sender] -= amount;
    totalSupply -= amount;
    emit Transfer(msg.sender, address(0), amount);
}

}