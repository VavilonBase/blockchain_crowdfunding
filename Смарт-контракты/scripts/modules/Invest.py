class Invest:
    ''' uint256 investNumber; // уникальный номер инвестиции
        uint256 projectNumber; // номер проекта
        address author; // адрес автора проекта
        address investor; // адрес инвестора
        uint256 investAmount; // сумма инвестиции
        bool moneyAcceptFlg; // флаг принятия денежных средств'''
    def __init__(self, invest_number, project_number, author, investor, invest_amount, money_accept_flg):
        self.invest_number = invest_number
        self.project_number = project_number
        self.author = author
        self.investor = investor
        self.invest_amount = invest_amount
        self.money_accept_flg = money_accept_flg
    def __str__(self):
        return f'''---------------------------
                Номер проекта: {self.project_number}
                Номер инвестиции: {self.invest_number}
                Адрес автора проекта: {self.author}
                Адрес инвестора: {self.investor}
                Сумма инвестиции: {self.invest_amount}
                Флаг принятия денежных средств: {self.money_accept_flg}
                ---------------------------'''

    def __eq__(self, other):
        return (self.project_number == other.project_number and
                self.invest_number == other.invest_number and
                self.author == other.author and
                self.investor == other.investor and
                self.invest_amount == other.invest_amount and
                self.money_accept_flg == other.money_accept_flg)