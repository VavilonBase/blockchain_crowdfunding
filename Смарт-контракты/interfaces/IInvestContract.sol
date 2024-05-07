// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title IInvestContract
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */


interface IInvestContract {
    function summaryProjectInvestors(uint256 projectNumber, address author) external;
    function getProjectInvestors(uint256 projectNumber, address author) external view returns(address[] memory);

}