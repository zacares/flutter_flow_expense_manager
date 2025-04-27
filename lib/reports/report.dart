import "package:flow/data/exchange_rates.dart";

abstract class FlowReport {
  final ExchangeRates? rates;
  final String primaryCurrency;

  const FlowReport({required this.rates, required this.primaryCurrency});

  bool get ready;

  bool get missingExchangeRates => rates == null;

  bool get showMissingExchangeRatesWarning;
}
