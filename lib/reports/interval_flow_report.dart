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
  late double _averageIncome;
  late double _averageExpense;
  late double _averageFlow;

  /// Median of sum by interval, in the primary currency.
  late double _medianExpense;

  /// Average of sum by interval, in the primary currency.
  late double _totalIncome;
  late double _totalExpense;
  late double _totalFlow;

  Money get averageIncome => Money(_averageIncome, primaryCurrency);
  Money get averageExpense => Money(_averageExpense, primaryCurrency);
  Money get averageFlow => Money(_averageFlow, primaryCurrency);
  Money get totalIncome => Money(_totalIncome, primaryCurrency);
  Money get totalExpense => Money(_totalExpense, primaryCurrency);
  Money get totalFlow => Money(_totalFlow, primaryCurrency);
  Money get medianExpense => Money(_medianExpense, primaryCurrency);

  bool _showMissingExchangeRatesWarning = false;

  IntervalFlowReport({
    required this.interval,
    required this.rangeData,
    required super.rates,
    required super.primaryCurrency,
  }) {
    _init();
  }

  @override
  bool get showMissingExchangeRatesWarning => _showMissingExchangeRatesWarning;

  void _init() {
    bool hasNonPrimaryCurrency = false;

    for (final Transaction transaction in rangeData.transactions) {
      if (transaction.isDeleted == true) {
        continue;
      }

      if (transaction.isTransfer == true) {
        continue;
      }

      if (!rangeData.range.contains(transaction.transactionDate)) {
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

    _totalIncome = 0.0;
    _totalExpense = 0.0;
    _totalFlow = 0.0;

    final List<DateTime> sortedKeys = data.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    int? firstIncomeIndex;
    int? firstExpenseIndex;
    int? firstFlowIndex;

    for (int i = 0; i < sortedKeys.length; i++) {
      final DateTime startOfInterval = sortedKeys[i];
      final SingleCurrencyFlow flow = data[startOfInterval]!;

      if (flow.incomeSum > 0 && firstIncomeIndex == null) {
        firstIncomeIndex = i;
      }
      if (flow.expenseSum < 0 && firstExpenseIndex == null) {
        firstExpenseIndex = i;
      }
      if (flow.flow != 0 && firstFlowIndex == null) {
        firstFlowIndex = i;
      }

      if (firstIncomeIndex != null) {
        _totalIncome += flow.incomeSum;
      }

      if (firstExpenseIndex != null) {
        _totalExpense += flow.expenseSum;
      }

      if (firstFlowIndex != null) {
        _totalFlow += flow.flow;
      }
    }

    int incomeCount = sortedKeys.length - (firstIncomeIndex ?? 0);
    int expenseCount = sortedKeys.length - (firstExpenseIndex ?? 0);
    int flowCount = sortedKeys.length - (firstFlowIndex ?? 0);

    for (final DateTime startOfInterval in sortedKeys.reversed) {
      final SingleCurrencyFlow flow = data[startOfInterval]!;

      if (firstIncomeIndex != null) {
        if (flow.incomeSum <= 0) {
          incomeCount--;
        } else {
          firstIncomeIndex = null;
        }
      }

      if (firstExpenseIndex != null) {
        if (flow.expenseSum >= 0) {
          expenseCount--;
        } else {
          firstExpenseIndex = null;
        }
      }

      if (firstFlowIndex != null) {
        if (flow.flow == 0) {
          flowCount--;
        } else {
          firstFlowIndex = null;
        }
      }
    }

    _averageIncome = _totalIncome / incomeCount.toDouble();
    _averageExpense = _totalExpense / expenseCount.toDouble();
    _averageFlow = _totalFlow / flowCount.toDouble();

    final List<double> sortedExpenses =
        data.values.map((flow) => flow.expenseSum).toList()
          ..sort((a, b) => a.compareTo(b));

    _medianExpense = sortedExpenses.length.isEven
        ? (sortedExpenses[sortedExpenses.length ~/ 2 - 1] +
                  sortedExpenses[sortedExpenses.length ~/ 2]) *
              0.5
        : sortedExpenses[sortedExpenses.length ~/ 2];

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
