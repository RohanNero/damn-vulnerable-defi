// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'hardhat/console.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../DamnValuableToken.sol';

/**
 * @title PuppetPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract PuppetPool is ReentrancyGuard {
    using Address for address payable;

    mapping(address => uint256) public deposits;
    address public immutable uniswapPair;
    DamnValuableToken public immutable token;

    event Borrowed(
        address indexed account,
        uint256 depositRequired,
        uint256 borrowAmount
    );

    constructor(address tokenAddress, address uniswapPairAddress) {
        token = DamnValuableToken(tokenAddress);
        uniswapPair = uniswapPairAddress;
    }

    // Allows borrowing `borrowAmount` of tokens by first depositing two times their value in ETH
    function borrow(uint256 borrowAmount) public payable nonReentrant {
        uint256 depositRequired = calculateDepositRequired(borrowAmount);
        //console.log('depositRequired: ', depositRequired);

        require(
            msg.value >= depositRequired,
            'Not depositing enough collateral'
        );

        if (msg.value > depositRequired) {
            payable(msg.sender).sendValue(msg.value - depositRequired);
        }

        deposits[msg.sender] = deposits[msg.sender] + depositRequired;

        // Fails if the pool doesn't have enough tokens in liquidity
        require(token.transfer(msg.sender, borrowAmount), 'Transfer failed');

        emit Borrowed(msg.sender, depositRequired, borrowAmount);
    }

    // we want this to be small as possible considering we only have 25 ETH
    // 100,000 * oraclePrice * 2
    // 100,000 * .001 * 2 =
    function calculateDepositRequired(
        uint256 amount
    ) public view returns (uint256) {
        return (amount * _computeOraclePrice() * 2) / 10 ** 18;
    }

    // The more DVT tokens the pool has, the smaller this number will be
    function _computeOraclePrice() private view returns (uint256) {
        // calculates the price of the token in wei according to Uniswap pair
        //console.log('pair address: ', uniswapPair);
        //console.log('ETH balance: ', uniswapPair.balance);
        //console.log('DVT balance: ', token.balanceOf(uniswapPair));
        return
            (uniswapPair.balance * (10 ** 18)) / token.balanceOf(uniswapPair);
        // 10 ETH / 10 DVT tokens
        // 10 ETH / 1010 DVT tokens = 0.001
    }

    /**
     ... functions to deposit, redeem, repay, calculate interest, and so on ...
     */
}
