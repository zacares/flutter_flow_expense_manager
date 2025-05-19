import "package:flow/data/multi_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/reports/report.dart";

class IntervalFlowReport extends FlowReport {
  final RangeData rangeData;
  final Duration interval;

  /// Map of start of range, [MultiCurrencyFlow]
  ///
  /// Uses [Namespace.nil] for uncategorized transactions
  final Map<DateTime, MultiCurrencyFlow> data = {};

  bool _showMissingExchangeRatesWarning = false;

  IntervalFlowReport({
    required this.interval,
    required this.rangeData,
    required super.rates,
    required super.primaryCurrency,
  }) {
    init();
  }

  @override
  bool get showMissingExchangeRatesWarning => _showMissingExchangeRatesWarning;

  void init() {
    bool hasNonPrimaryCurrency = false;

    for (final Transaction transaction in rangeData.transactions) {
      if (rangeData.range.contains(transaction.transactionDate) == false) {
        continue;
      }

      if (transaction.currency != primaryCurrency) {
        hasNonPrimaryCurrency = true;
      }

      final DateTime associatedInterval = _getInterval(
        transaction.transactionDate,
      );

      data[associatedInterval] ??= MultiCurrencyFlow();
      data[associatedInterval]!.add(transaction.money);
    }

    if (hasNonPrimaryCurrency && rates == null) {
      _showMissingExchangeRatesWarning = true;
    }
  }

  DateTime _getInterval(DateTime transactionDate) {
    final int value =
        transactionDate.millisecondsSinceEpoch -
        rangeData.range.from.millisecondsSinceEpoch;

    final int intervalValue = value ~/ interval.inMilliseconds;

    return DateTime.fromMillisecondsSinceEpoch(
      rangeData.range.from.millisecondsSinceEpoch +
          (intervalValue * interval.inMilliseconds),
    );
  }
}
