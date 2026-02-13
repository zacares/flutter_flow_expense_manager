import Foundation

struct RecordedTransaction: Codable {
    let id: UUID
    let amount: Double
    let note: String
    let transactionDate: Date
    let type: TransactionType

    init(
        id: UUID = UUID(),
        amount: Double,
        note: String = "",
        transactionDate: Date = Date(),
        type: TransactionType = .expense
    ) {
        self.id = id
        self.amount = amount
        self.note = note
        self.createdAt = createdAt
        self.type = type
    }
}
