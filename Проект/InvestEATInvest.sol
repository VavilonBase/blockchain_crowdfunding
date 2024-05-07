// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title InvestEATProject
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import "contracts/IInvestEATInvest.sol";
import "contracts/IInvestEATProject.sol";


contract InvestEATInvest is IInvestEATInvest {

    struct UnderInvest {
        uint256 number; // номер подынвестиции
        uint256 numberProject; // номер проекта
        uint256 numberInvest; // номер инвестиции
        address investor; // адрес инвестора
        bool investFlg; // флаг подтверждения инвестиции
        bool moneyAcceptFlg; // флаг принятия денежных средств
        uint256 investAmount; // сумма инвестиции
    }

    struct Invest {
        uint256 number; // уникальный номер инвестиции
        uint256 numberProject; // номер проекта
        address addressGuard; // адрес хранителя денежных средств
        bool status; // true - открыт; false - закрыт
        string uMoneyAccount; // номер счета на ЮMoney адреса хранителя денежных средств
        address author; // адресс автора проекта
        uint256 totalAmount; // общая сумма инвестиций
        uint256 necessaryAmount; // требуемая сумма
        UnderInvest[] underInvests; // словарь/массив подинвестиций
        uint256 underInvestNumber; // номера уникальных идентификаторов подынвестиций
    }

    uint256 investNumber = 0; // номера уникальных идентификаторов инвестиций
    IInvestEATProject investEATProjectContract; // смарт-контракт "Проект"

    // номер проекта => Инвестиция)
    mapping(uint256 => Invest) investsProjects; // все инвестиции в проекты 

    address owner; // владелец контракта (некоторые функции доступны только владельцу)
    address investEATProject; // адрес смарт-контракта "Проект"
    address investEATPay; // адрес смарт-контракта "Выплата"
    

    modifier onlyOwner() { // модификатор доступа только для владельца
        require(msg.sender == owner, unicode"Нет доступа!");
        _;
    }

    modifier onlyProject() { // модификатор доступа только для смарт-контракта "Проект"
        require(msg.sender == investEATProject, unicode"Нет доступа!");
        _;
    }

    modifier onlyPay() { // модификатор доступа только для смарт-контракта "Выплата"
        require(msg.sender == investEATPay, unicode"Нет доступа!");
        _;
    }

    constructor() {
        owner = msg.sender; // назначение владельца контракта
    }

    function changeInvestEATProject(address adrInvestEATProject) external onlyOwner { // функция смены адреса смарт-контракта "Проект"
        investEATProject = adrInvestEATProject;
    }

    function changeInvestEATPay(address adrInvestEATPay) external onlyOwner { // функция смены адреса смарт-контракта "Выплата"
        investEATPay = adrInvestEATPay;
    }  

    function createInvest(uint256 numberProject, address addressGuard, string memory uMoneyAccount, address author, uint256 necessaryAmount) external onlyProject { // Функция создания инвестиции при создании проекта
        // Инициализируем значения
        investsProjects[numberProject].number = investNumber;
        investsProjects[numberProject].addressGuard = addressGuard;
        investsProjects[numberProject].author = author;
        investsProjects[numberProject].numberProject = numberProject;
        investsProjects[numberProject].status = true;
        investsProjects[numberProject].totalAmount = 0;
        investsProjects[numberProject].uMoneyAccount = uMoneyAccount;
        investsProjects[numberProject].necessaryAmount = necessaryAmount;
        investsProjects[numberProject].underInvestNumber = 0;

        investNumber = investNumber + 1;
    }

    // Инвестирование
    function invest(uint256 numberProject, uint investAmount) public { // Функция создания инвестиции при создании проекта
        // Проверяем, что инвестиция существует
        require(investsProjects[numberProject].status == true, unicode"Проверьте, существует ли проект и открыт ли он для инвестирования");
        // Получаем номер подынвестиции
        uint256 underInvestNumber = investsProjects[numberProject].underInvestNumber;

        // Создаем подынвестицию
        UnderInvest memory underInvest;
        underInvest.number = underInvestNumber; // Номер подынвестиции
        underInvest.numberProject = numberProject; // Номер проекта
        underInvest.numberInvest = investsProjects[numberProject].number; //  Номер инвестиции
        underInvest.investor = msg.sender; // Адресс инвестора
        underInvest.investAmount = investAmount; // Сумма инвестиций
        underInvest.moneyAcceptFlg = false;
        underInvest.investFlg = false;

        // Добавляем подынвестицию в инвестицию
        investsProjects[numberProject].underInvests[underInvestNumber] = underInvest;

        // Увеличение номера подынвестиций
        investsProjects[numberProject].underInvestNumber = investsProjects[numberProject].underInvestNumber + 1;
    }

    // Подтверждение приема денежных средств
    function assignGetMoney(uint256 numberProject, uint256 underInvestNumber) public {
        // Проверяем, что инвестиция существует
        require(investsProjects[numberProject].status == true, unicode"Проверьте, существует ли проект и открыт ли он для инвестирования");

        // Проверяем, что инициатор транзакции - держатель денежных средств
        require(investsProjects[numberProject].addressGuard == msg.sender, unicode"Вы не являетесь держателем денежных средств для данного проекта");

        // Проверяем, что денежные средства еще не принимались
        require(investsProjects[numberProject].underInvests[underInvestNumber].moneyAcceptFlg == false, unicode"Прием денежных средств уже подтвержден");


        // Проверяем, является ли автор проекта - держателем денежных средств
        if (investsProjects[numberProject].author == msg.sender) {
            // Если да, то выставляем оба флага
            investsProjects[numberProject].underInvests[underInvestNumber].moneyAcceptFlg = true;
            investsProjects[numberProject].underInvests[underInvestNumber].investFlg = true;

            address author = investsProjects[numberProject].author; // Автор проекта
            uint256 investAmount = investsProjects[numberProject].underInvests[underInvestNumber].investAmount; // Сумма инвестиций

            // Изменяем сумму инвестиций
            investEATProjectContract.changeInvestAmount(numberProject, author, investAmount);

            // Говорим, что автору выплачены все средства
        } else {
            // Если нет, то выставляем только флаг принятия денежных средств
            investsProjects[numberProject].underInvests[underInvestNumber].moneyAcceptFlg = true;
        }
    }

    // Подтверждение прием инвестиции
    function assignInvest(uint256 numberProject, uint256 underInvestNumber) public {
        // Проверяем, что инвестиция существует
        require(investsProjects[numberProject].status == false, unicode"Проверьте, существует ли проект и открыт ли он для инвестирования");

        // Проверяем, что инициатор транзакции - автор проекта
        require(investsProjects[numberProject].author == msg.sender, unicode"Вы не являетесь автором данного проекта");

        // Проверяем, что инвестиция еще не подтверждалась
        require(investsProjects[numberProject].underInvests[underInvestNumber].moneyAcceptFlg == false, unicode"Инвестиция уже была подтверждена");

        // Выставляем флаг принятия инвестиции
        investsProjects[numberProject].underInvests[underInvestNumber].investFlg = true;

        // Изменяем сумму инвестиций
        address author = investsProjects[numberProject].author; // Автор проекта
        uint256 investAmount = investsProjects[numberProject].underInvests[underInvestNumber].investAmount; // Сумма инвестиций

        investEATProjectContract.changeInvestAmount(numberProject, author, investAmount);
    }

    // Получение всех инвестиций в проект
    function getAllUnderInvests(uint256 numberProject) public view returns(UnderInvest[] memory) {
        // Проверяем, что инвестиция существует
        require(investsProjects[numberProject].author != 0x0000000000000000000000000000000000000000, unicode"Проверьте, существует ли проект");

        return investsProjects[numberProject].underInvests;
    }
}