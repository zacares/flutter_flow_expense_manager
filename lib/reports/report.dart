import "package:flow/data/exchange_rates.dart";
import "package:flow/entity/transaction.dart";
import "package:moment_dart/moment_dart.dart";

abstract class FlowReport {
  final ExchangeRates? rates;
  final String primaryCurrency;

  const FlowReport({required this.rates, required this.primaryCurrency});

  bool get missingExchangeRates => rates == null;

  bool get showMissingExchangeRatesWarning;
}

class RangeData {
  final TimeRange range;
  final List<Transaction> transactions;

  RangeData({required this.range, required this.transactions})
    : assert(transactions.every((t) => range.contains(t.transactionDate)));
}
