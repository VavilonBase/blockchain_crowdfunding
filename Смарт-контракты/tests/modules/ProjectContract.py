from brownie import ProjectContract as project_smart_contract
from .Project import Project

class ProjectContract:
    def __init__(self, _from):
        self.project_contract = project_smart_contract.deploy({'from': _from})

    def change_umoney_account(self, umoney_account, _from):
        self.project_contract.changeUMoneyAccount(umoney_account, {'from': _from})
    
    def convert_from_solidity(self, projects):
        returned_projects = list()
        for project in projects:
            returned_projects.append(Project(*project))
        return returned_projects
    
    def add_new_project(self, title, url, necessary_ammount, _from):
        self.project_contract.addNewProject(title, url, necessary_ammount, {'from': _from})

    def check_project_exists_and_open(self, project_number, author, _from):
        return self.project_contract.checkProjectExistsAndOpen(project_number, author, {'from': _from})

    def get_all_user_projects(self, author, _from):
        return self.convert_from_solidity(self.project_contract.getAllUserProjects(author, {'from': _from}))
    
    def get_all_projects(self, _from):
        return self.project_contract.getAllProjects({'from': _from})

