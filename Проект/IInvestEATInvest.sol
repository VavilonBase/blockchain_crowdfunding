// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title IInvestEATInvest
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */


interface IInvestEATInvest {
    function createInvest(uint256 numberProject, address addressGuard, string memory uMoneyAccount, address author, uint256 necessaryAmount) external;
}