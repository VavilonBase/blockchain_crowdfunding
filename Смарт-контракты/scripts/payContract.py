from brownie import accounts
from .modules.PayContract import PayContract
from .modules.ProjectContract import ProjectContract
from .modules.InvestContract import InvestContract
from .modules.Invest import Invest
import csv

def main():
    # Данные для тестирования
    acc = accounts[0]
    project_contract = ProjectContract(acc)
    invest_contract = InvestContract(acc)
    pay_contract = PayContract(acc)

    invest_contract.change_project_contract(project_contract.project_contract.address, acc)
    invest_contract.change_pay_contract(pay_contract.pay_contract.address, acc)
    project_contract.change_invest_contract(invest_contract.invest_contract.address, acc)
    project_contract.change_pay_contract(pay_contract.pay_contract.address, acc)
    pay_contract.change_invest_contract(invest_contract.invest_contract.address, acc)
    pay_contract.change_project_contract(project_contract.project_contract.address, acc)

    invest_test = Invest(0, 0, accounts[1], accounts[5], 32, False)

    # Тестирование изменения адреса соседних контрактов
    assert pay_contract.get_address_project_contract(acc) == project_contract.project_contract.address

    # Загружаем инвестиции и проекты
    project_contract.load_csv(accounts)
    invest_contract.load_csv(accounts)

    # Принимаем часть инвестиций
    invest_contract.assign_get_money(0, accounts[2], 0, acc)
    invest_contract.assign_get_money(0, accounts[2], 1, acc)
    invest_contract.assign_get_money(0, accounts[3], 0, acc)
    invest_contract.assign_get_money(0, accounts[3], 1, acc)

    # Закрываем проекты
    project_contract.close_project(0, accounts[2], acc)
    project_contract.close_project(0, accounts[3], acc)

    user_projects = project_contract.get_all_user_projects(accounts[3], acc)
    for project in user_projects:
        print(project)

    # Запрашиваем выплату
    pay_contract.request_pay(0, 80_000, 'На мощный компьютер', accounts[3])
    pays = pay_contract.get_all_pays_project(0, accounts[3], accounts[3])
    for pay in pays:
        print(pay)

    print(pay_contract.get_pay_vote(pays[0].project_number, pays[0].author, pays[0].pay_number, acc))

    pay_contract.vote(pays[0].project_number, pays[0].author, pays[0].pay_number, True, accounts[5])
    pay_contract.vote(pays[0].project_number, pays[0].author, pays[0].pay_number, True, accounts[7])
    pay_contract.pay(pays[0].project_number, pays[0].author, pays[0].pay_number, acc)
    print(pay_contract.get_pay_vote(pays[0].project_number, pays[0].author, pays[0].pay_number, acc))
    for project in project_contract.get_all_projects(acc):
        print(project)
