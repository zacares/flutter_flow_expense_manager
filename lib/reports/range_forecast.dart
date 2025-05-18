import "package:flow/data/money.dart";
import "package:flow/data/money_flow.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/reports/report.dart";
import "package:moment_dart/moment_dart.dart";

class RangeForecast extends FlowReport {
  final RangeData previousRangeData;

  /// The duration doesn't have to same as the previous range,
  /// and it will be aligned to the end of the previous range.
  final RangeData currentRangeData;

  late final MoneyFlow forecast;

  bool _showMissingExchangeRatesWarning = false;

  RangeForecast({
    required super.rates,
    required super.primaryCurrency,
    required this.previousRangeData,
    required this.currentRangeData,
  }) {
    init();
  }

  void init() {
    if (previousRangeData.transactions.isEmpty) {
      throw StateError("Previous transactions cannot be empty");
    }

    bool hasNonPrimaryCurrency = false;

    final MoneyFlow previousFlow = previousRangeData.transactions
        .where((t) => previousRangeData.range.contains(t.transactionDate))
        .map((t) => t.money)
        .fold(MoneyFlow(), (total, current) => total..add(current));

    if (previousFlow.uniqueCurrencies.any(
      (currency) => currency != primaryCurrency,
    )) {
      hasNonPrimaryCurrency = true;
    }

    final MoneyFlow currentFlow = currentRangeData.transactions
        .map((t) => t.money)
        .fold(MoneyFlow(), (total, current) => total..add(current));

    if (!hasNonPrimaryCurrency &&
        currentFlow.uniqueCurrencies.any(
          (currency) => currency != primaryCurrency,
        )) {
      hasNonPrimaryCurrency = true;
    }

    if (hasNonPrimaryCurrency && rates == null) {
      _showMissingExchangeRatesWarning = true;
    }

    late final Money previousTotalExpense;
    late final Money previousTotalIncome;
    late final Money currentTotalExpense;
    late final Money currentTotalIncome;

    if (rates == null || _showMissingExchangeRatesWarning) {
      previousTotalExpense = previousFlow.getExpenseByCurrency(primaryCurrency);
      previousTotalIncome = previousFlow.getIncomeByCurrency(primaryCurrency);
      currentTotalExpense = currentFlow.getExpenseByCurrency(primaryCurrency);
      currentTotalIncome = currentFlow.getIncomeByCurrency(primaryCurrency);
    } else {
      previousTotalExpense = previousFlow.getTotalExpense(
        rates!,
        primaryCurrency,
      );
      previousTotalIncome = previousFlow.getTotalIncome(
        rates!,
        primaryCurrency,
      );
      currentTotalExpense = currentFlow.getTotalExpense(
        rates!,
        primaryCurrency,
      );
      currentTotalIncome = currentFlow.getTotalIncome(rates!, primaryCurrency);
    }

    final double previousExpensePerSecond =
        previousTotalExpense.amount /
        previousRangeData.range.duration.inSeconds;
    final double previousIncomePerSecond =
        previousTotalIncome.amount / previousRangeData.range.duration.inSeconds;

    final TimeRange currentSpannedRange = currentRangeData.range.from.rangeTo(
      currentRangeData.transactions.range?.to ??
          currentRangeData.transactions.firstOrNull?.transactionDate ??
          currentRangeData.range.from,
    );

    final Duration remainingCurrentRange =
        currentSpannedRange.duration - currentSpannedRange.duration;

    forecast =
        MoneyFlow()..addAll([
          Money(
            currentTotalIncome.amount +
                (previousIncomePerSecond * remainingCurrentRange.inSeconds),
            primaryCurrency,
          ),
          Money(
            currentTotalExpense.amount +
                (previousExpensePerSecond * remainingCurrentRange.inSeconds),
            primaryCurrency,
          ),
        ]);
  }

  @override
  bool get showMissingExchangeRatesWarning => _showMissingExchangeRatesWarning;
}
