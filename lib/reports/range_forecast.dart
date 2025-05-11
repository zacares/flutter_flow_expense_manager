import "package:flow/data/money_flow.dart";
import "package:flow/entity/transaction.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/reports/report.dart";
import "package:moment_dart/moment_dart.dart";

class RangeForecast extends FlowReport {
  final RangeData previousRangeData;
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

    late final double previousExpensePerSecond;
    late final double previousIncomePerSecond;

    late final double currentExpensePerSecond;
    late final double currentIncomePerSecond;

    if (rates == null || _showMissingExchangeRatesWarning) {
      previousExpensePerSecond =
          previousFlow.getExpenseByCurrency(primaryCurrency).amount /
          previousRangeData.range.duration.inSeconds;
      previousIncomePerSecond =
          previousFlow.getIncomeByCurrency(primaryCurrency).amount /
          previousRangeData.range.duration.inSeconds;
    } else {
      previousExpensePerSecond =
          previousFlow.getTotalExpense(rates!, primaryCurrency).amount /
          previousRangeData.range.duration.inSeconds;
      previousIncomePerSecond =
          previousFlow.getTotalIncome(rates!, primaryCurrency).amount /
          previousRangeData.range.duration.inSeconds;
    }

    final TimeRange currentSpannedRange = currentRangeData.range.from.rangeTo(
      currentRangeData.transactions.range?.to ??
          currentRangeData.transactions.firstOrNull?.transactionDate ??
          currentRangeData.range.from,
    );
  }

  @override
  bool get showMissingExchangeRatesWarning => _showMissingExchangeRatesWarning;
}
