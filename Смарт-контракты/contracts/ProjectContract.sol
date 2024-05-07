// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title ProjectContract
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import "interfaces/IInvestContract.sol";
import "interfaces/IProjectContract.sol";

contract ProjectContract is IProjectContract {
    modifier onlyOwner() { // модификатор доступа только для владельца
        require(msg.sender == owner, unicode"Нет доступа!");
        _;
    }

    struct Project {
        uint256 number; // уникальный номер проекта
        address author; // адрес автора проекта
        address addressGuard; // адрес хранителя денежных средств
        string uMoneyAccount; // счет владельца смарт-контратка на ЮMoney
        uint8 status; // 0 - идет сбор средств, 1 - собрано, 2 - не собрано, 3 - выплачено, 4 - инвестиции возвращены
        string title; // название проекта
        string url; // ссылка на проект
        uint256 necessaryAmount; // Требуемая сумма инвестиций
        uint256 amountInvest; // общая сумма инвестиций в проект в руб.
        uint256 amountPay; // общая сумма выплат
    }

    // Адрес пользователя -> проект
    mapping(address => Project[]) usersProjects; // проекты пользователей

    // Адреса всех авторов проектов
    address[] authorAddresses;

    // Общее кол-во проектов
    uint256 countProjects = 0;

    address owner; // владелец контракта (некоторые функции доступны только владельцу)
    string uMoneyAccount; // счет владельца смарт-контратка на ЮMoney

    address public addrInvestContract; // адрес смарт-контракта "Инвестиция"
    IInvestContract investContract; // смарт-контракт "Инвестиция"
   
    address public addrPayContract; // адрес смарт-контракта "Выплата"

    constructor() {
        owner = msg.sender; // назначение владельца контракта
    }

    // функция смены адреса смарт-контракта "Инвестиция"
    function changeInvestContract(address _addrInvestContract) external onlyOwner { 
        addrInvestContract = _addrInvestContract;
        investContract = IInvestContract(_addrInvestContract);
    }
    
    // функция смены адреса смарт-контракта "Выплата"
    function changePayContract(address _addrPayContract) external onlyOwner { 
        addrPayContract = _addrPayContract;
    }  

    // Функция смены счета 
    function changeUMoneyAccount(string memory _uMoneyAccount) external onlyOwner { 
        uMoneyAccount = _uMoneyAccount;
    }  

    // Добавление нового проекта
    function addNewProject(string memory title, string memory url, uint256 necessaryAmount) public { 
        address author = msg.sender;
        uint256 projectNumber = usersProjects[author].length;
        Project memory project = Project(
            projectNumber,
            author,
            owner,
            uMoneyAccount,
            0,
            title,
            url,
            necessaryAmount,
            0,
            0
        ); // создание нового проекта

        usersProjects[msg.sender].push(project); // добавление проекта в словарь


        // Если пользователь создает проект первый раз, то добавляем его в массив авторов
        if (projectNumber == 0) {
            authorAddresses.push(msg.sender);
        }
        
        // Увеличиваем кол-во проектов
        countProjects++;
    }

    // Получение всех проектов автора
    function getAllUserProjects(address author) public view returns(Project[] memory){ 
        return usersProjects[author];
    }

    // Изменение количества инвестиций
    function changeInvestAmount(uint256 projectNumber, address author, uint256 amountInvest) external override {
        require(msg.sender == addrInvestContract, unicode"Нет доступа!");
        usersProjects[author][projectNumber].amountInvest += amountInvest;
    }

    // Изменение суммы выплат
    function changePayAmount(uint256 projectNumber, address author, uint256 amountPay) external override {
        require(msg.sender == addrPayContract, unicode"Нет доступа!");
        require(this.checkNecessaryMoney(projectNumber, author, amountPay), unicode'Недостаточно средств');

        usersProjects[author][projectNumber].amountPay += amountPay;

        // Проверяем, выплачены ли все средства
        if (usersProjects[author][projectNumber].amountPay == usersProjects[author][projectNumber].amountInvest) {
            usersProjects[author][projectNumber].status = 3;
        }
    }

    // Проверка существования проекта
    function checkProjectExists(uint256 projectNumber, address author) external view returns (bool){
        return projectNumber < usersProjects[author].length;
    }

    // Проверка существования проекта
    function checkProjectExistsAndOpen(uint256 projectNumber, address author) external view override returns (bool){
        return this.checkProjectExists(projectNumber, author) && usersProjects[author][projectNumber].status == 0;
    }

    // Проверка существования проекта и его готовности к выплатам
    function checkProjectExistsAndReadyToPayments(uint256 projectNumber, address author) external view override returns (bool){
        return this.checkProjectExists(projectNumber, author) && usersProjects[author][projectNumber].status == 1;
    }

    // Истечение времени сбора
    function closeProject(uint256 projectNumber, address author) external onlyOwner{
        require(this.checkProjectExistsAndOpen(projectNumber, author) == true, unicode'Проект закрыт или не существует');
        investContract.summaryProjectInvestors(projectNumber, author);

        // Если проект существует и открыт, то проверяем собрано ли нужное кол-во средств
        Project memory project = usersProjects[author][projectNumber];
        if (project.amountInvest < project.necessaryAmount) {
            project.status = 2; // Не собрано необходимое кол-во средств
        } else {
            project.status = 1; // Собрано необходимое кол-во средств
        }

        usersProjects[author][projectNumber] = project;
    }

    // Возврат инвестиций
    function returnInvest(uint256 projectNumber, address author) external onlyOwner {
        require(this.checkProjectExists(projectNumber, author) == true, unicode'Проекта не существует');
        
        // Проверка, что проект действительно требует возврата инвестиций
        Project memory project = usersProjects[author][projectNumber];
        require(project.status == 2, unicode'Проект не требует возврата инвестиций');
        
        // Если проект требуется возврата инвестиций, то говорим, что инвестиции возвращены
        project.status = 4;

        usersProjects[author][projectNumber] = project;
    } 

    // Получение всех проектов
    function getAllProjects() external view returns (Project[] memory){
        Project[] memory projects = new Project[](countProjects);

        uint256 index = 0;

        for (uint256 i = 0; i < authorAddresses.length; i++) {
            Project[] memory authorProjects = usersProjects[authorAddresses[i]];
            for (uint256 j = 0; j < authorProjects.length; j++) {
                projects[index] = authorProjects[j];
                index++;
            }

        }

        return projects;
    }

    // Проверка наличия необходимых денежных средств 
    function checkNecessaryMoney(uint256 projectNumber, address author, uint256 _amountPay) external view override returns (bool) {
        uint256 amountInvest = usersProjects[author][projectNumber].amountInvest;
        uint256 amountPay = usersProjects[author][projectNumber].amountPay;
        return (amountInvest - amountPay) >= _amountPay;
    }
}

