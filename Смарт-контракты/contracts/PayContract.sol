// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title PayContract
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
/*
    На одобрение/отклонение выплаты дается 7 дней, если в течение этого времени инвестор не проголосует, то выплата автоматически одобряется
*/

import "interfaces/IProjectContract.sol";
import "interfaces/IInvestContract.sol";
import "interfaces/IPayContract.sol";

contract PayContract is IPayContract{
    modifier onlyOwner() { // модификатор доступа только для владельца
        require(msg.sender == owner, unicode"Нет доступа!");
        _;
    }
    
    struct Pay {
        uint256 payNumber; // номер выплаты
        uint256 projectNumber; // номер проекта
        address author; // автор проекта
        uint256 amountPay; // требуемая выплата
        string message; // описание назначения выплаты
        uint8 status; // статус выплаты: 0 - выплата зарегистрирована, 1 - выплата одобрена, 2 - выплата отклонена, 3 - выплачено
    }

    struct Vote {
        uint256 payNumber; // номер выплаты
        uint256 projectNumber; // номер проекта
        address author; // автор проекта
        bool flg; // true - принята, false - отклонена/еще идет голосование
        address[] requireInvestors; // все инвесторы, которые должны проголосовать
        address[] yesInvestors; // одобрившие выплату инвесторы
        address[] noInvestors; // отклонившие выплату инвесторы
        address[] voteInvestors; // Проголосовавшие инвесторы
    }

    address owner; // Адрес владельца смарт-контракта

    // Адрес автора проекта => (номер проекта => Массив выплат)
    mapping(address => mapping(uint256 => Pay[])) payments; // Все выплаты

    // Адрес автора проекта => (номер проекта => (номер выплаты => голосование))
    mapping(address => mapping(uint256 => mapping(uint256 => Vote))) votes; // голосования

    address public addrProjectContract; // адрес смарт-контракта "Проект"
    IProjectContract projectContract; // смарт-контракт "Проект"

    address public addrInvestContract; // адрес смарт-контракта "Инвестиция"
    IInvestContract investContract; // смарт-контракт "Инвестиция"

    constructor() {
        owner = msg.sender; // назначение владельца контракта
    }

    // функция смены адреса смарт-контракта "Проект"
    function changeProjectContract(address _addrProjectContract) external onlyOwner { 
        addrProjectContract = _addrProjectContract;
        projectContract = IProjectContract(_addrProjectContract);
    }

    // Получение адреса смарт-контракта "Проект"
    function getAddressProjectContract() external view returns(address) {
        return addrProjectContract;
    }

    // функция смены адреса смарт-контракта "Инвестиция"
    function changeInvestContract(address _addrInvestContract) external onlyOwner { 
        addrInvestContract = _addrInvestContract;
        investContract = IInvestContract(_addrInvestContract);
    }

    // Получение всех выплат проекта
    function getAllPaysProject(uint256 projectNumber, address author) external view returns (Pay[] memory) {
        return payments[author][projectNumber];
    }

    // Получение голосования
    function getPayVote(uint256 projectNumber, address author, uint256 payNumber) external view returns(Vote memory) {
        return votes[author][projectNumber][payNumber];
    }

    // Запрос на выплату
    function requestPay(uint256 projectNumber, uint256 amountPay, string memory message) external {
        address author = msg.sender;
        // Проверить, что проект существует, готов к выплатам, и сразу же проверить, что автор является отправителем запроса
        require(projectContract.checkProjectExistsAndReadyToPayments(projectNumber, author) == true, unicode"Проверьте, существует ли проект и готов к выплатам");

        // Проверить, что есть запрашиваемые средства
        require(projectContract.checkNecessaryMoney(projectNumber, author, amountPay) == true, unicode"Недостаточно средств");

        // Добавить запрос о выплате в хранилище
        uint256 payNumber = payments[author][projectNumber].length;
        Pay memory pay = Pay(
            payNumber,
            projectNumber,
            author,
            amountPay,
            message,
            0
        );

        payments[author][projectNumber].push(pay);

        // Назначить голосование
        Vote memory vote;
        vote.payNumber = payNumber;
        vote.projectNumber = projectNumber;
        vote.author = author;
        vote.flg = false;
        vote.requireInvestors = investContract.getProjectInvestors(projectNumber, author);

        votes[author][projectNumber][payNumber] = vote;
    }

    // Голосование. flg = true - за, flg = false - против
    function vote(uint256 projectNumber, address author, uint256 payNumber, bool flg) external {
        // Проверяем, что голосование еще не завершено
        require(payments[author][projectNumber][payNumber].status == 0, unicode'Голосвание завершено');

        address investor = msg.sender;
        Vote memory vote = votes[author][projectNumber][payNumber];
        address[] memory investors = vote.requireInvestors;

        // Проверяем, что инвестора есть в списке инвесторов
        bool existsFlg = false;
        for (uint256 i = 0; i < investors.length; i++) {
            if (investors[i] == investor) {
                existsFlg = true;
            }
        }
        require(existsFlg = true, unicode'Такого инвестора нет в списке');

        // Проверяем, что инвестор еще не голосовал    
        for (uint256 i = 0; i < vote.voteInvestors.length; i++) {
            require(vote.voteInvestors[i] != investor, unicode'Вы уже голосовали');
        }

        // Добавляем инвестора в список голосвавших и распределяем его в список за/против
        votes[author][projectNumber][payNumber].voteInvestors.push(investor);
        if (flg == true) {
            votes[author][projectNumber][payNumber].yesInvestors.push(investor);
        } else {
            votes[author][projectNumber][payNumber].noInvestors.push(investor);
        }

        vote = votes[author][projectNumber][payNumber];

        // Смотрим, что голосование еще не завершилось
        // Если кол-во инвесторов за > кол-во против + нейтральные, то считаем голосование завершенным
        uint256 allLen = vote.requireInvestors.length;
        uint256 voteLen = vote.voteInvestors.length;
        uint256 yesLen = vote.yesInvestors.length;
        uint256 noLen = vote.noInvestors.length;
        uint256 neutralLen = allLen - voteLen;
        
        if (yesLen > noLen + neutralLen) {
            // Считаем голосование завершенным
            votes[author][projectNumber][payNumber].flg = true; // одобрено
            payments[author][projectNumber][payNumber].status = 1;
        }
    }

    // Закрытие голосования по истечению времени
    function closeVote(uint256 projectNumber, address author, uint256 payNumber) external onlyOwner {
        // Проверяем, что голосование еще не завершено
        require(payments[author][projectNumber][payNumber].status == 0, unicode'Голосование завершено');
        
        Vote memory vote = votes[author][projectNumber][payNumber];
        // Если кол-во инвесторов за + нейтральные > кол-во против, то считаем голосование завершенным и выплату одобренной
        // Все воздержавшиеся инвесторы автоматически одобряют выплату
        uint256 allLen = vote.requireInvestors.length;
        uint256 voteLen = vote.voteInvestors.length;
        uint256 yesLen = vote.yesInvestors.length;
        uint256 noLen = vote.noInvestors.length;
        uint256 neutralLen = allLen - voteLen;

        if (yesLen + neutralLen > noLen) {
            // Считаем голосование завершенным
            votes[author][projectNumber][payNumber].flg = true; // одобрено
            payments[author][projectNumber][payNumber].status = 1;
        } else {
            votes[author][projectNumber][payNumber].flg = false; // одобрено
            payments[author][projectNumber][payNumber].status = 2;
        }
    }

    // Выплата денег пользователю
    function pay(uint256 projectNumber, address author, uint256 payNumber) external onlyOwner {
        // Проверяем, что требуется выплатить средства
        require(payments[author][projectNumber][payNumber].status == 1, unicode'Выплата не одобрена');

        projectContract.changePayAmount(projectNumber, author, payments[author][projectNumber][payNumber].amountPay);
        payments[author][projectNumber][payNumber].status = 3;


    } 

}