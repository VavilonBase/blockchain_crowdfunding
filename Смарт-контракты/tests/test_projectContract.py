import pytest
from .modules.ProjectContract import ProjectContract
from .modules.Project import Project

umoney_account = ''

project1 = Project()

@pytest.fixture
def project_contract(ProjectContract, accounts):
    umoney_account = '32412312123'
    project1 = Project(0, accounts[1], accounts[0], umoney_account, 0, "Проект 1", "https://vk.com/im", 200_000, 0, 0)

    # Выкладываем контракт
    acc = accounts[0]

    project_contract = ProjectContract(acc)

    # Меняем счет юМонеу
    project_contract.change_umoney_account(umoney_account, acc)

    # Добавляем новые проекты
    # Пользователь 1
    # Проект 1
    acc1 = accounts[1]
    project_contract.add_new_project("Проект 1", "https://vk.com/im", 200_000, acc1)
    
    # Проект 2
    project_contract.add_new_project("Проект 2", "https://vk.com/im2", 500_000, acc1)

    # Пользователь 2
    # Проект 1
    acc2 = accounts[2]
    project_contract.add_new_project("Проект 1", "https://vk.com/act21", 1_000_000, acc2)
    
    # Пользователь 3
    # Проект 1
    acc3 = accounts[3]
    project_contract.add_new_project("Проект 1", "https://vk.com/act333", 50_000, acc3)


    return project_contract

def test_project_contract(project_contract, accounts):
    acc1 = accounts[1]
    acc2 = accounts[2]
    acc3 = accounts[3]

    # Получение проектов
    projects1 = project_contract.get_all_user_projects(acc1, acc1)
    projects2 = project_contract.get_all_user_projects(acc2, acc2)
    projects3 = project_contract.get_all_user_projects(acc3, acc3)
    
    # Проверка по кол-ву
    assert len(projects1) == 2
    assert len(projects2) == 1
    assert len(projects3) == 1

    # Проверка счет uMoney
    assert projects1[0].umoney_account == umoney_account

    # Проверка, что у проектов статус равен 0 (открыты)
    assert projects2[0].status == 0

    # Проверка равенства проетков
    assert projects1[0] == project1




