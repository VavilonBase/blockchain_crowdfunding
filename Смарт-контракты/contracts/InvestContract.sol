// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title InvestEATProject
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import "interfaces/IInvestContract.sol";
import "interfaces/IProjectContract.sol";


contract InvestContract is IInvestContract {

    modifier onlyOwner() { // модификатор доступа только для владельца
        require(msg.sender == owner, unicode"Нет доступа!");
        _;
    }

    modifier onlyProject() { // модификатор доступа только для смарт-контракта "Проект"
        require(msg.sender == addrProjectContract, unicode"Нет доступа!");
        _;
    }

    modifier onlyPay() { // модификатор доступа только для смарт-контракта "Выплата"
        require(msg.sender == addrPayContract, unicode"Нет доступа!");
        _;
    }

    struct Invest {
        uint256 investNumber; // уникальный номер инвестиции
        uint256 projectNumber; // номер проекта
        address author; // адрес автора проекта
        address investor; // адрес инвестора
        uint256 investAmount; // сумма инвестиции
        bool moneyAcceptFlg; // флаг принятия денежных средств
    }

    address public addrProjectContract; // адрес смарт-контракта "Проект"
    IProjectContract projectContract; // смарт-контракт "Проект"
    address public addrPayContract; // адрес смарт-контракта "Выплата"

    // Адрес автора проекта => (номер проекта => Инвестиции)
    mapping(address => mapping(uint256 => Invest[])) investsProjects; // все инвестиции в проекты 

    // адрес инвестора => Инвестиции
    mapping(address => Invest[]) investsInvestor; // все инвестиции инвестора

    // Адрес автора проекта => (номер проекта => массив инвесторов)
    mapping(address => mapping(uint256 => address[])) projectInvestors;

    address owner; // владелец контракта (некоторые функции доступны только владельцу)
    
    constructor() {
        owner = msg.sender; // назначение владельца контракта
    }

    // функция смены адреса смарт-контракта "Проект"
    function changeProjectContract(address _addrProjectContract) external onlyOwner { 
        addrProjectContract = _addrProjectContract;
        projectContract = IProjectContract(_addrProjectContract);
    }

    // функция смены адреса смарт-контракта "Выплата"
    function changePayContract(address _addrPayContract) external onlyOwner { 
        addrPayContract = _addrPayContract;
    }  

    // Инвестирование
    function invest(uint256 projectNumber, address author, uint256 investAmount) public { // Функция создания инвестиции при создании проекта
        // Проверяем, что проект существует и открыт
        require(projectContract.checkProjectExistsAndOpen(projectNumber, author) == true, unicode"Проверьте, существует ли проект и открыт ли он для инвестирования");
        
        // Получаем номер инвестиции
        uint256 investNumber = investsProjects[author][projectNumber].length;

        // Создаем инвестицию
        Invest memory inv;
        inv.investNumber = investNumber; // Номер инвестиции
        inv.projectNumber = projectNumber; // Номер проекта
        inv.author = author; // Адрес автора проекта
        inv.investor = msg.sender; // Адрес инвестора
        inv.investAmount = investAmount; // Сумма инвестиций
        inv.moneyAcceptFlg = false; // Флаг принятия денежных средств

        // Добавляем инвестицию
        investsProjects[author][projectNumber].push(inv);
        investsInvestor[msg.sender].push(inv);
    }

    // Получение всех инвестиций в проект
    function getAllInvestsIntoProject(uint256 projectNumber, address author) external view returns(Invest[] memory) {
        return investsProjects[author][projectNumber];
    }

    // Получение всех инвестиций инвестора
    function getAllInvestorInvests(address investor) external view returns(Invest[] memory) {
        return investsInvestor[investor];
    }

    // Подтверждение приема денежных средств
    function assignGetMoney(uint256 projectNumber, address author, uint256 investNumber) external onlyOwner {
        // Проверяем, что проект сущетсвует и открыт
        require(projectContract.checkProjectExistsAndOpen(projectNumber, author) == true, unicode"Проверьте, существует ли проект и открыт ли он для инвестирования");
        
        // Проверяем, что денежные средства еще не принимались
        require(investsProjects[author][projectNumber][investNumber].moneyAcceptFlg == false, unicode"Прием денежных средств уже подтвержден");

        // Меняем статус в инвестициях
        investsProjects[author][projectNumber][investNumber].moneyAcceptFlg = true;

        // Меняем статус в инвестициях инвестора
        address investor = investsProjects[author][projectNumber][investNumber].investor;
        Invest[] memory _investsInvestor = investsInvestor[investor];

        for (uint256 i = 0; i < _investsInvestor.length; i++) {
            if (_investsInvestor[i].projectNumber == projectNumber && _investsInvestor[i].author == author &&
                _investsInvestor[i].investNumber == investNumber) {
                    investsInvestor[investor][i].moneyAcceptFlg = true;
                    break;
                }
        }
        
        // Изменяем сумму инвестиций в проекте
        projectContract.changeInvestAmount(projectNumber, author, investsProjects[author][projectNumber][investNumber].investAmount);
    }

    // Отбираем всех инвесторов проекта
    function summaryProjectInvestors(uint256 projectNumber, address author) external onlyProject override{
        // Получаем все инвестиции в проект
        Invest[] memory invests = investsProjects[author][projectNumber];

        // Проходимся по всем инвестициям и добавляем инвесторов
        for (uint256 i = 0; i < invests.length; i++) {
            address investor = invests[i].investor;
            if (invests[i].moneyAcceptFlg) {
                bool flg = true;
                for (uint256 j = 0; j < projectInvestors[author][projectNumber].length; j++) {
                    if (projectInvestors[author][projectNumber][j] == investor) {
                        flg = false;
                        break;
                    }
                }
                if (flg) {
                    projectInvestors[author][projectNumber].push(investor);
                }
            }
        }
    }

    // Получение всех инвесторов проекта
    function getProjectInvestors(uint256 projectNumber, address author) external view override returns(address[] memory){
        return projectInvestors[author][projectNumber];
    }
    
}