import "package:flow/entity/transaction.dart";
import "package:flow/reports/report.dart";

class TitleFrequencyReport extends FlowReport {
  final List<Transaction> transactions;

  /// Map of case insensitive title, count of transactions for that title
  final Map<String, int> data = {};

  TitleFrequencyReport({
    required super.rates,
    required super.primaryCurrency,
    required this.transactions,
  }) {
    init();
  }

  void init() {
    for (final Transaction transaction in transactions) {
      final String? key = transaction.title?.trim().toLowerCase();

      if (key == null || key.isEmpty) {
        continue;
      }

      if (data[key] == null) {
        data[key] = 1;
      } else {
        data[key] = data[key]! + 1;
      }
    }
  }

  @override
  bool get showMissingExchangeRatesWarning => false;
}
