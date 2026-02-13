import Foundation

enum TransactionType: String, Codable {
    case income
    case expense
}

struct RecordedTransaction: Codable {
    let id: UUID
    let amount: Double
    let title: String?
    let notes: String?
    let fromAccount: String?
    let toAccount: String?
    let category: String?
    let transactionDate: Date
    let type: TransactionType

    init(
        id: UUID = UUID(),
        amount: Double,
        title: String?,
        fromAccount: String?,
        toAccount: String?,
        category: String?,
        notes: String?,
        transactionDate: Date = Date(),
        type: TransactionType = .expense
    ) {
        self.id = id
        self.amount = amount
        self.title = title
        self.notes = notes
        self.fromAccount = fromAccount
        self.toAccount = toAccount
        self.category = category
        self.transactionDate = transactionDate
        self.type = type
    }
}
