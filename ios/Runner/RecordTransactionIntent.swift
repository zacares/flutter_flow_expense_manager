import AppIntents

struct RecordTransactionIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Transaction"
    static var description: IntentDescription = "Log transactions from Siri."

    @Parameter(title: "Account")
    var account: String

    @Parameter(title: "Amount")
    var amount: Double

    @Parameter(title: "Category")
    var category: String

    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        let tx = RecordedTransaction(amount: amount, note: category)
        try RecordedTransactionService.append(tx)
        return .result(value: "Recorded transaction for \(account): $\(amount) in category \(category).")
    }
}
