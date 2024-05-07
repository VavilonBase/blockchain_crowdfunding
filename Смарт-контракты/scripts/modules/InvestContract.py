from brownie import InvestContract as invest_smart_contract
from .Invest import Invest
import csv

class InvestContract:
    def __init__(self, _from):
        self.invest_contract = invest_smart_contract.deploy({'from': _from})
    
    def change_project_contract(self, address, _from):
        self.invest_contract.changeProjectContract(address, {'from': _from})

    def change_pay_contract(self, address, _from):
        self.invest_contract.changePayContract(address, {'from': _from})

    def get_project_contract_address(self, _from):
        return self.invest_contract.addrProjectContract({'from': _from})
    
    def load_csv(self, accounts):
        with open('.\scripts\data\invests.csv', newline='', encoding='utf-8') as csv_file:
            spam_reader = csv.reader(csv_file, delimiter=',', quotechar='|')
            for row in spam_reader:
                self.invest(row[0], accounts[int(row[1])], int(row[2]), accounts[int(row[3])])
    
    def invest(self, project_number, author, invest_ammount, _from):
        self.invest_contract.invest(project_number, author, invest_ammount, {'from':_from})
    
    def convert_from_solidity(self, invests):
        returned_invests = list()
        for invest in invests:
            returned_invests.append(Invest(*invest))
        return returned_invests

    def get_all_invests_into_project(self, project_number, author, _from):
        return self.convert_from_solidity(self.invest_contract.getAllInvestsIntoProject(project_number, author, {'from':_from}))
    
    def get_all_investor_invests(self, investor, _from):
        return self.convert_from_solidity(self.invest_contract.getAllInvestorInvests(investor, {'from':_from}))
    
    def assign_get_money(self, project_number, author, invest_number, _from):
        self.invest_contract.assignGetMoney(project_number, author, invest_number, {'from':_from})

    def get_project_investors(self, project_number, author, _from):
        return self.invest_contract.getProjectInvestors(project_number, author, {'from':_from})