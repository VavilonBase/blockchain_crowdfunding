// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title InvestEATProject
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import "contracts/IInvestEATInvest.sol";
import "contracts/IInvestEATProject.sol";

contract InvestEATProject is IInvestEATProject {

    struct Project {
        uint256 number; // уникальный номер проекта
        address author; // адрес автора проекта
        bool status; // true - открыт; false - закрыт
        string title; // название проекта
        string url; // ссылка на проект
        uint256 amountInvest; // общая сумма инвестиций в проект в руб.
        uint256 amountPay; // общая сумма выплат
    }

    mapping(address => Project[]) usersProjects; // проекты пользователей

    address owner; // владелец контракта (некоторые функции доступны только владельцу)
    address investEATInvest; // адрес смарт-контракта "Инвестиция"
    IInvestEATInvest investEATInvestContract; // смарт-контракт "Инвестиция"
   
    address investEATPay; // адрес смарт-контракта "Выплата"

    uint256 projectNumber = 0; // номера уникальных идентификаторов проектов

    modifier onlyOwner() { // модификатор доступа только для владельца
        require(msg.sender == owner, unicode"Нет доступа!");
        _;
    }

    modifier onlyInvest() { // модификатор доступа только для смарт-контракта "Инвестиция"
        require(msg.sender == investEATInvest, unicode"Нет доступа!");
        _;
    }

    modifier onlyPay() { // модификатор доступа только для смарт-контракта "Выплата"
        require(msg.sender == investEATPay, unicode"Нет доступа!");
        _;
    }

    constructor() {
        owner = msg.sender; // назначение владельца контракта
    }

    function changeInvestEATInvest(address adrInvestEATInvest) external onlyOwner { // функция смены адреса смарт-контракта "Инвестиция"
        investEATInvest = adrInvestEATInvest;
        investEATInvestContract = IInvestEATInvest(adrInvestEATInvest);
    }

    function changeInvestEATPay(address adrInvestEATPay) external onlyOwner { // функция смены адреса смарт-контракта "Выплата"
        investEATPay = adrInvestEATPay;
    }  

    function addNewProject(string memory title, string memory url, address addressGuard, string memory uMoneyAccount, uint256 necessaryAmount) public { // Добавление нового проекта
        Project memory project = Project(
            projectNumber,
            msg.sender,
            true,
            title,
            url,
            0,
            0
        ); // создание нового проекта

        usersProjects[msg.sender].push(project); // добавление проекта в словарь

        investEATInvestContract.createInvest(projectNumber, addressGuard, uMoneyAccount, msg.sender, necessaryAmount); // Создание инвестиции
    
        // Увеличиваем номер проекта
        projectNumber ++;
    }

    function getAllUserProjects(address user) public view returns(Project[] memory){ // получение всех проектов пользователя
        Project[] memory projects = usersProjects[user];
        return projects;
    }

    // Изменение количества инвестиций
    function changeInvestAmount(uint256 projectNum, address author, uint256 investAmount) external onlyInvest {
        usersProjects[author][projectNum].amountInvest += investAmount;
    }
}

