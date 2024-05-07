class Vote:
    ''' uint256 payNumber; // номер выплаты
        uint256 projectNumber; // номер проекта
        address author; // автор проекта
        bool flg; // true - принята, false - отклонена/еще идет голосование
        address[] requireInvestors; // все инвесторы, которые должны проголосовать
        address[] yesInvestors; // одобрившие выплату инвесторы
        address[] noInvestors; // отклонившие выплату инвесторы
        address[] voteInvestors; // Проголосовавшие инвесторы'''
    def __init__(self, pay_number, project_number, author, flg, require_investors, yes_investors, no_investors, vote_investors):
        self.pay_number = pay_number
        self.project_number = project_number
        self.author = author
        self.flg = flg
        self.require_investors = require_investors
        self.yes_investors = yes_investors
        self.no_investors = no_investors
        self.vote_investors = vote_investors
    def __str__(self):
        return f'''---------------------------
                Номер проекта: {self.project_number}
                Номер выплаты: {self.pay_number}
                Адрес автора проекта: {self.author}
                Статус голосования: {self.flg}
                Инвесторы, которые должны проголосовать: {self.require_investors}
                Одобрившие выплату инвесторы: {self.yes_investors}
                Отклонившие выплату инвесторы: {self.no_investors}
                ---------------------------'''

    def __eq__(self, other):
        return (self.project_number == other.project_number and
                self.pay_number == other.pay_number and
                self.author == other.author)