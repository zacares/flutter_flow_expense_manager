import "dart:math" as math;

import "package:auto_size_text/auto_size_text.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flow/data/money.dart";
import "package:flow/reports/interval_flow_report.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/chart_legend.dart";
import "package:flow/widgets/general/money_text.dart";
import "package:flow/widgets/general/spinner.dart";
import "package:flutter/widgets.dart";
import "package:moment_dart/moment_dart.dart";

class IntervalFlowReportView extends StatelessWidget {
  final IntervalFlowReport report;
  final IntervalFlowReport? compareWith;
  final AutoSizeGroup autoSizeGroup = AutoSizeGroup();

  final double height;
  final bool showLegend;

  bool get hasPrevious => compareWith != null;

  IntervalFlowReportView({
    super.key,
    required this.report,
    this.compareWith,
    this.height = 300.0,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    final LineChartData? dailyExpenditureChartData =
        prepareDailyExpenseChartData(context);

    final Widget child = Container(
      height: height,
      padding: EdgeInsets.all(16.0),
      child: dailyExpenditureChartData == null
          ? Spinner.center()
          : LineChart(dailyExpenditureChartData),
    );

    final String? previousLabel = compareWith?.rangeData.range.format();

    if (!showLegend || previousLabel == null) {
      return child;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            ChartLegend(
              color: context.colorScheme.primary,
              label: report.rangeData.range.format(),
            ),
            ChartLegend(
              color: context.colorScheme.primary.withAlpha(0x40),
              label: previousLabel,
            ),
          ],
        ),
      ],
    );
  }

  LineChartData? prepareDailyExpenseChartData(BuildContext context) {
    final int maxDays = calculateMaxDays(report.rangeData.range);

    final String primaryCurrency = UserPreferencesService().primaryCurrency;

    final Color currentPeriod = context.colorScheme.primary;
    final Color previousPeriod = context.colorScheme.primary.withAlpha(0x40);

    final Color textColor = context.colorScheme.onPrimary;

    return LineChartData(
      minX: 0.0,
      maxX: maxDays.toDouble(),
      minY: 0.0,
      // maxY: report.dailyMaxExpenditure.amount.abs(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (touchedSpot) => textColor,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final TextStyle textStyle = TextStyle(
                color: touchedSpot.bar.color,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              );
              final String amount = Money(
                touchedSpot.y,
                primaryCurrency,
              ).formattedCompact;
              return LineTooltipItem(amount, textStyle);
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: bottomTitles()),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => MoneyText(
              Money(value, primaryCurrency),
              initiallyAbbreviated: true,
              tapToToggleAbbreviation: false,
              autoSize: true,
              autoSizeGroup: autoSizeGroup,
              displayAbsoluteAmount: true,
            ),
            reservedSize: 48.0,
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: gridData(),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: report.averageExpense.amount.abs(),
            color: context.colorScheme.primary.withAlpha(0x40),
            label: HorizontalLineLabel(
              style: TextStyle(
                color: context.colorScheme.primary.withAlpha(0xc0),
                fontSize: 12.0,
              ),
              alignment: Alignment.topRight,
              labelResolver: (p0) =>
                  Money(p0.y, primaryCurrency).formattedCompact,
              show: true,
            ),
          ),
        ],
      ),
      borderData: borderData(context),
      lineBarsData: [
        LineChartBarData(
          barWidth: 2.0,
          color: currentPeriod,
          dotData: FlDotData(show: false),
          isStrokeCapRound: true,
          spots: report.data.entries
              .map(
                (entry) => FlSpot(
                  report.getInterval(entry.key).$2.toDouble(),
                  entry.value.expenseSum.abs(),
                ),
              )
              .toList(),
        ),
        if (hasPrevious)
          LineChartBarData(
            barWidth: 2.0,
            color: previousPeriod,
            dotData: FlDotData(show: false),
            isStrokeCapRound: true,
            spots: compareWith!.data.entries
                .map(
                  (entry) => FlSpot(
                    compareWith!.getInterval(entry.key).$2.toDouble(),
                    entry.value.expenseSum.abs(),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  FlBorderData borderData(BuildContext context) => FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(
        color: context.colorScheme.onSurface.withAlpha(0x40),
        width: 2.0,
      ),
      left: BorderSide(
        color: context.colorScheme.onSurface.withAlpha(0x40),
        width: 2.0,
      ),
      right: BorderSide.none,
      top: BorderSide.none,
    ),
  );

  int calculateMaxDays(TimeRange range) => switch (range) {
    DayTimeRange() => 1,
    MonthTimeRange() => math.max(
      range.from.endOfMonth().day,
      range.last.from.endOfMonth().day,
    ),
    TimeRange other => other.duration.inDays.abs(),
  };

  FlGridData gridData() {
    final double verticalInterval = switch (report.rangeData.range) {
      DayTimeRange() => 1.0,
      MonthTimeRange() => 5.0,
      YearTimeRange() => 30.0,
      _ => math.max(
        (report.rangeData.range.duration.inDays / 7.0).floorToDouble(),
        1,
      ),
    };

    // final double horizontalInterval = report.dailyAvgExpenditure.amount.abs();

    return FlGridData(
      show: true,
      // horizontalInterval: horizontalInterval > 0 ? horizontalInterval : null,
      verticalInterval: verticalInterval,
    );
  }

  SideTitles bottomTitles() {
    return switch (report.rangeData.range) {
      MonthTimeRange() => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) =>
            Text((value + 1.0).toStringAsFixed(0)),
        interval: 3,
        minIncluded: true,
        maxIncluded: false,
      ),
      YearTimeRange yearTimeRange => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          final int month = yearTimeRange.from.isLeapYear
              ? [
                  0,
                  31,
                  60,
                  91,
                  121,
                  152,
                  182,
                  213,
                  244,
                  274,
                  303,
                  333,
                ].indexOf(value.toInt())
              : [
                  0,
                  31,
                  59,
                  90,
                  120,
                  151,
                  181,
                  212,
                  243,
                  273,
                  302,
                  332,
                ].indexOf(value.toInt());

          if (month < 0) return const SizedBox.shrink();

          return Text(DateTime(1970, month + 1).toMoment().format("MMM"));
        },
        interval: 1,
        minIncluded: true,
        maxIncluded: true,
      ),
      _ => SideTitles(showTitles: false),
    };
  }
}
