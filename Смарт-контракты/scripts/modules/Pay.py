class Pay:
    ''' uint256 payNumber; // номер выплаты
        uint256 projectNumber; // номер проекта
        address author; // автор проекта
        uint256 amountPay; // требуемая выплата
        string message; // описание назначения выплаты
        uint8 status; // статус выплаты: 0 - выплата зарегистрирована, 1 - выплата одобрена, 2 - выплата отклонена, 3 - выплачено'''
    def __init__(self, pay_number, project_number, author, amount_pay, message, status):
        self.pay_number = pay_number
        self.project_number = project_number
        self.author = author
        self.amount_pay = amount_pay
        self.message = message
        self.status = status
    def __str__(self):
        return f'''---------------------------
                Номер проекта: {self.project_number}
                Номер выплаты: {self.pay_number}
                Адрес автора проекта: {self.author}
                Требуемая выплата: {self.amount_pay}
                Описание назначения выплаты: {self.message}
                Статус выплаты: {self.status}
                ---------------------------'''

    def __eq__(self, other):
        return (self.project_number == other.project_number and
                self.pay_number == other.pay_number and
                self.author == other.author and
                self.amount_pay == other.amount_pay and
                self.message == other.message and
                self.status == other.status)