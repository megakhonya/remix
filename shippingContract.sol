// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
 
contract Shipping{
 
    enum ship{
        pending,
        shipped,
        accepted,
        rejected,
        canceled
    }
 
    ship public mike;
     // Returns uint
    // Pending  - 0
    // Shipped  - 1
    // Accepted - 2
    // Rejected - 3
    // Canceled - 4
 
    function get() public view returns(ship) {
    return mike;
    }
 
    function set(ship _x) public {
    mike = _x;
    }

    function cancel() public {
       mike = ship.canceled;
    }
 
    function reset() public {
        delete mike;
    }
}