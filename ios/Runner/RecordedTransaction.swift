import Foundation

struct RecordedTransaction: Codable {
    let id: UUID
    let amount: Double
    let note: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        note: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.note = note
        self.createdAt = createdAt
    }
}
