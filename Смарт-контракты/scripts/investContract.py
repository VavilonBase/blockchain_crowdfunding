from brownie import accounts
from .modules.InvestContract import InvestContract
from .modules.ProjectContract import ProjectContract
from .modules.Invest import Invest
import csv

def main():
    # Данные для тестирования
    acc = accounts[0]
    project_contract = ProjectContract(acc)
    invest_contract = InvestContract(acc)
    
    invest_contract.change_project_contract(project_contract.project_contract.address, acc)
    project_contract.change_invest_contract(invest_contract.invest_contract.address, acc)
    invest_test = Invest(0, 0, accounts[1], accounts[5], 32, False)

    # Тестирование изменения адреса соседних контрактов
    assert invest_contract.get_project_contract_address(acc) == project_contract.project_contract.address

    # Подготовка данных для инвестирования
    project_contract.load_csv(accounts)
    invest_contract.load_csv(accounts)
    projects = project_contract.get_all_projects(acc)

    summary_invests = {}
    with open('.\scripts\data\invests.csv', newline='', encoding='utf-8') as csv_file:
            spam_reader = csv.reader(csv_file, delimiter=',', quotechar='|')
            for row in spam_reader:
                author = str(accounts[int(row[1])])
                project_number = int(row[0])
                summary_invests[author] = summary_invests.get(author, {project_number: 0})
                summary_invests[author][project_number] = summary_invests[author].get(project_number, 0) + 1

    test_invests = {}
    for project in projects:
        invests = invest_contract.get_all_invests_into_project(project.number, project.author, acc)
        for invest in invests:
            author = str(invest.author)
            project_number = invest.project_number
            test_invests[author] = summary_invests.get(author, {project_number: 0})
            test_invests[author][project_number] = summary_invests[author].get(project_number, 0) + 1

    summary_investor_invests = {}
    with open('.\scripts\data\invests.csv', newline='', encoding='utf-8') as csv_file:
            spam_reader = csv.reader(csv_file, delimiter=',', quotechar='|')
            for row in spam_reader:
                investor = str(accounts[int(row[3])])
                summary_investor_invests[investor] = summary_investor_invests.get(investor, 0) + 1
    acc5_invests = invest_contract.get_all_investor_invests(accounts[5], acc)

    # Тестирование
    # Проверка по кол-ву инвестиций в проекты
    for author in summary_invests.keys():
        for project_number in summary_invests[author].keys():
            assert summary_invests[author][project_number] == test_invests[author][project_number]

    # Проверка по кол-ву инвестиций у инвестора
    assert summary_investor_invests[str(accounts[5])] == len(acc5_invests), f'{summary_investor_invests[str(accounts[5])]=}={len(acc5_invests)=}' 

    # Проверка сравнения тестовой инвестиции
    for invest in acc5_invests:
         if invest.project_number == 0 and invest.author == accounts[1] and invest.invest_number == 0:
              assert invest == invest_test
    
    # Проверка того, что для всех инвестиций флаг принятия денежных средств равен 0
    test_invests = {}
    for project in projects:
        invests = invest_contract.get_all_invests_into_project(project.number, project.author, acc)
        for invest in invests:
            assert invest.money_accept_flg == False

    # Принимаем часть инвестиций
    invest_contract.assign_get_money(0, accounts[1], 0, acc)
    invest_contract.assign_get_money(0, accounts[2], 0, acc)
    invest_contract.assign_get_money(0, accounts[2], 1, acc)
    invest_contract.assign_get_money(0, accounts[3], 0, acc)
    invest_contract.assign_get_money(0, accounts[3], 1, acc)
    invest_contract.assign_get_money(1, accounts[4], 0, acc)

    # Проверяем, что у инвестиции инвестора тоже изменился флаг приема денежных средств
    acc5_invests = invest_contract.get_all_investor_invests(accounts[5], acc)
    for invest in acc5_invests:
        if invest.project_number == 0 and invest.invest_number == 1 and invest.author == accounts[2]:
            assert invest.money_accept_flg

    # Получение всех инвестиций в проекты
    projects = project_contract.get_all_projects(acc)
    all_invests = {}
    for project in projects:
        invests = invest_contract.get_all_invests_into_project(project.number, project.author, acc)
        for invest in invests:
            author = str(invest.author)
            project_number = invest.project_number
            invest_number = invest.invest_number
            all_invests[(author, project_number)] =  all_invests.get((author, project_number), {invest_number: invest})
            all_invests[(author, project_number)][invest_number] = invest

    # Тестирование
    assert all_invests[(str(accounts[1]), 0)][0].money_accept_flg == True
    assert all_invests[(str(accounts[2]), 0)][0].money_accept_flg == True
    assert all_invests[(str(accounts[2]), 0)][1].money_accept_flg == True
    assert all_invests[(str(accounts[3]), 0)][0].money_accept_flg == True
    assert all_invests[(str(accounts[3]), 0)][1].money_accept_flg == True
    assert all_invests[(str(accounts[4]), 1)][0].money_accept_flg == True

    for project in projects:
        if project.author == accounts[1] and project.number == 0:
              assert project.amount_invest == 32
        elif project.author == accounts[2] and project.number == 0:
              assert project.amount_invest == 281_000
        elif project.author == accounts[4] and project.number == 1:
              assert project.amount_invest == 95_000

    # Закрываем проекты
    acc = accounts[0]
    assert invest_contract.get_project_contract_address(acc) == project_contract.project_contract.address
    project_contract.close_project(0, accounts[2], acc)
    project_contract.close_project(0, accounts[3], acc)

    assert str(accounts[5]) in invest_contract.get_project_investors(0, accounts[2], acc)
    assert str(accounts[9]) in invest_contract.get_project_investors(0, accounts[2], acc)

    assert str(accounts[5]) in invest_contract.get_project_investors(0, accounts[3], acc)
    assert str(accounts[7]) in invest_contract.get_project_investors(0, accounts[3], acc)

    