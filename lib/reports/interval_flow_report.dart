import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/reports/report.dart";

/// A report that summarizes transactions in a given time range by intervals.
///
/// Everything is in the given [primaryCurrency]
class IntervalFlowReport extends FlowReport {
  final RangeData rangeData;
  final Duration interval;

  /// Map of start of range, [MultiCurrencyFlow]
  ///
  /// Uses [Namespace.nil] for uncategorized transactions
  final Map<DateTime, SingleCurrencyFlow> data = {};

  /// Average of sum by interval, in the primary currency.
  late Money _averageIncome;
  late Money _averageExpense;
  late Money _averageFlow;

  /// Average of sum by interval, in the primary currency.
  late Money _totalIncome;
  late Money _totalExpense;
  late Money _totalFlow;

  Money get averageIncome => _averageIncome;
  Money get averageExpense => _averageExpense;
  Money get averageFlow => _averageFlow;
  Money get totalIncome => _totalIncome;
  Money get totalExpense => _totalExpense;
  Money get totalFlow => _totalFlow;

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

      final (DateTime associatedInterval, int index) = getInterval(
        transaction.transactionDate,
      );

      data[associatedInterval] ??= SingleCurrencyFlow();
      data[associatedInterval]!.add(transaction.money, rates);
    }

    if (hasNonPrimaryCurrency && rates == null) {
      _showMissingExchangeRatesWarning = true;
    }

    int incomeCount = 0;
    int expenseCount = 0;
    int flowCount = 0;

    _totalIncome = Money(0.0, primaryCurrency);
    _totalExpense = Money(0.0, primaryCurrency);
    _totalFlow = Money(0.0, primaryCurrency);

    for (final SingleCurrencyFlow flow in data.values) {
      if (flow.incomeSum > 0) {
        _totalIncome += Money(flow.incomeSum, primaryCurrency);
        incomeCount += flow.incomeCount;
      }

      if (flow.expenseSum < 0) {
        _totalExpense += Money(flow.expenseSum, primaryCurrency);
        expenseCount += flow.expenseCount;
      }

      if (flow.flow != 0) {
        _totalFlow += Money(flow.flow, primaryCurrency);
        flowCount++;
      }
    }

    _averageIncome = totalIncome / incomeCount.toDouble();
    _averageExpense = totalExpense / expenseCount.toDouble();
    _averageFlow = totalFlow / flowCount.toDouble();

    // TODO @sadespresso account for insignificant values
  }

  (DateTime, int) getInterval(DateTime transactionDate) {
    final int value =
        transactionDate.millisecondsSinceEpoch -
        rangeData.range.from.millisecondsSinceEpoch;

    final int intervalValue = value ~/ interval.inMilliseconds;

    final DateTime startOfInterval = DateTime.fromMillisecondsSinceEpoch(
      rangeData.range.from.millisecondsSinceEpoch +
          (intervalValue * interval.inMilliseconds),
    );

    return (startOfInterval, intervalValue);
  }
}
