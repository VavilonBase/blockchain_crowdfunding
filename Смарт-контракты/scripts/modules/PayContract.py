from brownie import PayContract as pay_smart_contract
from .Pay import Pay
from .Vote import Vote

class PayContract:
    def __init__(self, _from):
        self.pay_contract = pay_smart_contract.deploy({'from': _from})
    
    def change_project_contract(self, address, _from):
        self.pay_contract.changeProjectContract(address, {'from': _from})

    def get_address_project_contract(self, _from):
        return self.pay_contract.getAddressProjectContract({'from': _from})

    def change_invest_contract(self, address, _from):
        self.pay_contract.changeInvestContract(address, {'from': _from})

    def get_all_pays_project(self, project_number, author, _from):
        return self.convert_from_solidity(self.pay_contract.getAllPaysProject(project_number, author, {'from': _from}))
    
    def get_pay_vote(self, project_number, author, pay_number, _from):
        return Vote(*self.pay_contract.getPayVote(project_number, author, pay_number, {'from':_from}))

    def vote(self, project_number, author, pay_number, flg, _from):
        self.pay_contract.vote(project_number, author, pay_number, flg, {'from': _from})

    def close_vote(self, project_number, author, pay_number, _from):
        self.pay_contract.closeVote(project_number, author, pay_number, {'from': _from})


    def pay(self, project_number, author, pay_number, _from):
        self.pay_contract.pay(project_number, author, pay_number, {'from':_from})

    def request_pay(self, project_number, amount_pay, message, _from):
        self.pay_contract.requestPay(project_number, amount_pay, message, {'from': _from})
    
    def convert_from_solidity(self, pays):
        returned_pays= list()
        for pay in pays:
            returned_pays.append(Pay(*pay))
        return returned_pays
