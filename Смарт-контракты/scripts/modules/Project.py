class Project:
    ''' uint256 number; // уникальный номер проекта
    address author; // адрес автора проекта
    address addressGuard; // адрес хранителя денежных средств
    string uMoneyAccount; // счет владельца смарт-контратка на ЮMoney
    bool status; // true - открыт; false - закрыт
    string title; // название проекта
    string url; // ссылка на проект
    uint256 necessaryAmount; // Требуемая сумма инвестиций
    uint256 amountInvest; // общая сумма инвестиций в проект в руб.
    uint256 amountPay; // общая сумма выплат'''
    def __init__(self, number, author, address_guard, umoney_account, status, title, url, necessary_ammount, amount_invest, amount_pay):
        self.number = number
        self.author = author
        self.address_guard = address_guard
        self.umoney_account = umoney_account
        self.status = status
        self.title = title
        self.url = url
        self.necessary_ammount = necessary_ammount
        self.amount_invest = amount_invest
        self.amount_pay = amount_pay

    def __str__(self):
        return f'''---------------------------
                Номер проекта: {self.number}
                Адрес автора проекта: {self.author}
                Адрес хранителя денежных средств: {self.address_guard}
                Счет на юMoney: {self.umoney_account}
                Статус по проекту: {self.status}
                Название проекта: {self.title}
                Ссылка на проект: {self.url}
                Необходимая сумма для сбора: {self.necessary_ammount}
                Общая сумма инвестиций: {self.amount_invest}
                Общая сумма выплат: {self.amount_pay}
                ---------------------------'''

    def __eq__(self, other):
        return (self.number == other.number and
                self.author == other.author and
                self.address_guard == other.address_guard and
                self.umoney_account == other.umoney_account and
                self.status == other.status and
                self.title == other.title and
                self.url == other.url and
                self.necessary_ammount == other.necessary_ammount and
                self.amount_invest == other.amount_invest and
                self.amount_pay == other.amount_pay)