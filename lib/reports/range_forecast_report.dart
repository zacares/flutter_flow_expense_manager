import "package:flow/data/money.dart";
import "package:flow/data/multi_currency_flow.dart";
import "package:flow/data/single_currency_flow.dart";
import "package:flow/objectbox/actions.dart";
import "package:flow/reports/report.dart";
import "package:moment_dart/moment_dart.dart";

class RangeForecastReport extends FlowReport {
  final RangeData previousRangeData;

  /// The duration doesn't have to same as the previous range,
  /// and it will be aligned to the end of the previous range.
  final RangeData currentRangeData;

  final SingleCurrencyFlow forecast = SingleCurrencyFlow();

  bool _showMissingExchangeRatesWarning = false;

  RangeForecastReport({
    required super.rates,
    required super.primaryCurrency,
    required this.previousRangeData,
    required this.currentRangeData,
  }) {
    _init();
  }

  void _init() {
    if (previousRangeData.transactions.isEmpty) {
      throw StateError("Previous transactions cannot be empty");
    }

    bool hasNonPrimaryCurrency = false;

    final MultiCurrencyFlow previousFlow = previousRangeData.transactions
        .where((t) => previousRangeData.range.contains(t.transactionDate))
        .map((t) => t.money)
        .fold(MultiCurrencyFlow(), (total, current) => total..add(current));

    if (previousFlow.uniqueCurrencies.any(
      (currency) => currency != primaryCurrency,
    )) {
      hasNonPrimaryCurrency = true;
    }

    final MultiCurrencyFlow currentFlow = currentRangeData.transactions
        .map((t) => t.money)
        .fold(MultiCurrencyFlow(), (total, current) => total..add(current));

    if (!hasNonPrimaryCurrency &&
        currentFlow.uniqueCurrencies.any(
          (currency) => currency != primaryCurrency,
        )) {
      hasNonPrimaryCurrency = true;
    }

    if (hasNonPrimaryCurrency && rates == null) {
      _showMissingExchangeRatesWarning = true;
    }

    final SingleCurrencyFlow previousMergedFlow = previousFlow.merge(
      primaryCurrency,
      rates,
    );
    final SingleCurrencyFlow currentMergedFlow = currentFlow.merge(
      primaryCurrency,
      rates,
    );

    final double previousExpensePerSecond =
        previousMergedFlow.totalExpense.amount /
        previousRangeData.range.duration.inSeconds;
    final double previousIncomePerSecond =
        previousMergedFlow.totalIncome.amount /
        previousRangeData.range.duration.inSeconds;

    final TimeRange currentSpannedRange = currentRangeData.range.from.rangeTo(
      currentRangeData.transactions.range?.to ??
          currentRangeData.transactions.firstOrNull?.transactionDate ??
          currentRangeData.range.from,
    );

    final Duration remainingCurrentRange =
        currentSpannedRange.duration - currentSpannedRange.duration;

    forecast.addAll([
      Money(
        currentMergedFlow.totalIncome.amount +
            (previousIncomePerSecond * remainingCurrentRange.inSeconds),
        primaryCurrency,
      ),
      Money(
        currentMergedFlow.totalExpense.amount +
            (previousExpensePerSecond * remainingCurrentRange.inSeconds),
        primaryCurrency,
      ),
    ], rates);
  }

  @override
  bool get showMissingExchangeRatesWarning => _showMissingExchangeRatesWarning;
}
