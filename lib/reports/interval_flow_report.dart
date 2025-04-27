import "package:flow/entity/transaction.dart";
import "package:flow/reports/report.dart";
import "package:moment_dart/moment_dart.dart";

class IntervalFlowReport extends FlowReport {
  final List<Transaction> transactions;
  final TimeRange? timeRange;
  final Duration interval;

  @override
  final bool ready = true;

  bool _showMissingExchangeRatesWarning = false;

  IntervalFlowReport({
    required this.timeRange,
    required this.interval,
    required this.transactions,
    required super.rates,
    required super.primaryCurrency,
  }) {
    init();
  }

  @override
  bool get showMissingExchangeRatesWarning => _showMissingExchangeRatesWarning;

  void init() {
    bool hasNonPrimaryCurrency = false;

    for (final Transaction transaction in transactions) {
      if (transaction.currency != primaryCurrency) {
        hasNonPrimaryCurrency = true;
        // TODO @sadespresso
      }
    }

    if (rates == null || hasNonPrimaryCurrency) {
      _showMissingExchangeRatesWarning = true;
    }
  }
}
