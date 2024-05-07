from brownie import accounts
from .modules.ProjectContract import ProjectContract
from .modules.Project import Project



def main():
    # Данные для тестирования   
    umoney_account = '32412312123'
    project_test = Project(0, accounts[3], accounts[0], umoney_account, 0, "Проект 1", "https://vk.com/act333", 50_000, 0, 0)
    adr_invest_contract = accounts[4]

    acc = accounts[0]
    project_contract = ProjectContract(acc)

    # Меняем счет юМонеу
    project_contract.change_umoney_account(umoney_account, acc)

    # Меняем адрес контракта "Инвестиции"
    project_contract.change_invest_contract(adr_invest_contract, acc)

    # Добавляем новые проекты
    project_contract.load_csv(accounts)
    acc1 = accounts[1]
    acc2 = accounts[2]
    acc3 = accounts[3]
    acc4 = accounts[4]

    # Получение проектов
    projects1 = project_contract.get_all_user_projects(acc1, acc1)

    projects2 = project_contract.get_all_user_projects(acc2, acc2)

    projects3 = project_contract.get_all_user_projects(acc3, acc3)
    
    projects4 = project_contract.get_all_user_projects(acc4, acc4)

    all_projects = project_contract.get_all_projects(acc1)

    # Тестирование
    # Проверка по кол-ву
    assert len(projects1) == 2
    assert len(projects2) == 1
    assert len(projects3) == 1
    assert len(projects4) == 2
    assert len(all_projects) == 6

    # Проверка равенства проектов
    assert projects3[0] == project_test
    
    # Проверка существования проектов
    assert project_contract.check_project_exists_and_open(1, acc1, acc1) == True
    assert project_contract.check_project_exists_and_open(3, acc1, acc1) == False

    # Проверка, что у всех проектов статус равен 0 (открыты)
    flg = True
    for project in all_projects:
        if project.status != 0:
            flg = False
    
    assert flg == True
    
    # Доп. действия
    # Изменение у проекта кол-во инвестиций
    project_contract.change_invest_amount(projects1[0].number, projects1[0].author, projects1[0].necessary_ammount, adr_invest_contract)

    # Закрытие проектов
    project_contract.close_project(projects1[0].number, projects1[0].author, acc)
    project_contract.close_project(projects1[1].number, projects1[1].author, acc)
    
    projects1 = project_contract.get_all_user_projects(acc1, acc1)

    # Тестирование
    assert projects1[0].status == 1
    assert projects1[1].status == 2

    # Доп. действия
    # Возвращаем инвестиции
    project_contract.return_invest(projects1[1].number, projects1[1].author, acc)
    
    projects1 = project_contract.get_all_user_projects(acc1, acc1)

    # Тестирование
    assert projects1[1].status == 4

