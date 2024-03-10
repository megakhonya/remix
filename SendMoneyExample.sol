// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SendMoneyExample{

    uint public balanceReceived;

    function receiveMoney() public payable {
        balanceReceived += msg.value;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdrawMoney() public {
        address payable to = payable(msg.sender);
        uint balance = this.getBalance();
        require(balance > 0, "Contract balance is zero");
        to.transfer(balance);
    }

    function withdrawMoneyTo(address payable _to) public {
        uint balance = this.getBalance();
        require(balance > 0, "Contract balance is zero");
        _to.transfer(balance);
    }
}


