// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract simpleStorage{
    uint storeData = 25;
    
    function set (uint x) public {
         storeData = x;
    }

    function get () public view returns (uint) {
        return storeData;
    }
}

contract simpleStorge2{
    uint storeData2 = 55;

    function set (uint w) public {
        storeData2 = (5*w);
    }

    function get () public view returns (uint) {
        return storeData2;
    }
}

contract simpleStorage3{
    string name = "Joe";

    function set (string memory _name) pure public {
        _name = "Pundo";
    }

    function get () public view returns (string memory) {
        return name;
    }
}