import "package:flow/l10n/extensions.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/widgets/general/modal_overflow_bar.dart";
import "package:flow/widgets/general/modal_sheet.dart";
import "package:flow/widgets/general/wavy_divider.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

/// Pops with a moment_dart compatible date formatter string
/// from a pre-defined list of patterns.
class SelectDateFormat extends StatefulWidget {
  static const List<String> patterns = [
    "YYYY-MM-DD",
    "MM/DD/YYYY",
    "DD/MM/YYYY",
    "YYYY/M/D",
    "YYYY/MM/DD",
    "YYYY.MM.DD",
    "YYYY M D",
    "MM-DD-YYYY",
    "MM.DD.YYYY",
    "YYYY MMM D",
    "MMMM D, YYYY",
    "MMM D, YYYY",
    "MMM D YYYY",
    "DD.MM.YYYY",
    "DD-MM-YYYY",
    "D M YYYY",
    "D MMM YY",
    "D MMM YYYY",
    "D MMM, YYYY",
    "D MMMM YY",
    "D MMMM YYYY",
    "D MMMM, YYYY",
    "D-M-YY",
    "D-M-YYYY",
    "D-MMM-YY",
    "D-MMM-YYYY",
    "D-MMMM-YY",
    "D-MMMM-YYYY",
    "D.M.YY",
    "D.M.YYYY",
    "D.MMM.YY",
    "D.MMM.YYYY",
    "D.MMMM.YY",
    "D.MMMM.YYYY",
    "D/M/YY",
    "D/M/YYYY",
    "D/MMM/YY",
    "D/MMM/YYYY",
    "D/MMMM/YY",
    "D/MMMM/YYYY",
    "DD MM YY",
    "DD MM YYYY",
    "DD-MM-YY",
    "DD.MM.YY",
    "DD/MM/YY",
    "M D YY",
    "M D YYYY",
    "M-D-YY",
    "M-D-YYYY",
    "M.D.YY",
    "M.D.YYYY",
    "M/D/YY",
    "M/D/YYYY",
    "MM DD YY",
    "MM DD YYYY",
    "MM, DD, YY",
    "MM, DD, YYYY",
    "MM-DD-YY",
    "MM.DD.YY",
    "MM/DD/YY",
    "MMM D YY",
    "MMM-D-YY",
    "MMM-D-YYYY",
    "MMM.D.YY",
    "MMM.D.YYYY",
    "MMM/D/YY",
    "MMM/D/YYYY",
    "YY D M",
    "YY D MMM",
    "YY D MMMM",
    "YY DD MM",
    "YY M D",
    "YY MM DD",
    "YY MMM D",
    "YY MMMM D",
    "YY-D-M",
    "YY-D-MMM",
    "YY-D-MMMM",
    "YY-DD-MM",
    "YY-M-D",
    "YY-MM-DD",
    "YY-MMM-D",
    "YY-MMMM-D",
    "YY.D.M",
    "YY.D.MMM",
    "YY.D.MMMM",
    "YY.DD.MM",
    "YY.M.D",
    "YY.MM.DD",
    "YY.MMM.D",
    "YY.MMMM.D",
    "YY/D/M",
    "YY/D/MMM",
    "YY/D/MMMM",
    "YY/DD/MM",
    "YY/M/D",
    "YY/MM/DD",
    "YY/MMM/D",
    "YY/MMMM/D",
    "YYYY D M",
    "YYYY D MMM",
    "YYYY D MMMM",
    "YYYY DD MM",
    "YYYY MM DD",
    "YYYY MMMM D",
    "YYYY-D-M",
    "YYYY-D-MMM",
    "YYYY-D-MMMM",
    "YYYY-DD-MM",
    "YYYY-M-D",
    "YYYY-MMM-D",
    "YYYY-MMMM-D",
    "YYYY.D.M",
    "YYYY.DD.MM",
    "YYYY.M.D",
    "YYYY.MMM.D",
    "YYYY/D/M",
    "YYYY/DD/MM",
  ];

  const SelectDateFormat({super.key});

  @override
  State<SelectDateFormat> createState() => _SelectDateFormatState();
}

class _SelectDateFormatState extends State<SelectDateFormat> {
  String? selectedPattern;

  @override
  void initState() {
    super.initState();
    selectedPattern = UserPreferencesService().customDateFormatter;
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text("preferences.dateFormat".t(context)),
      leading: DefaultTextStyle(
        style: context.textTheme.displaySmall!,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8.0,
          children: [
            Text(
              DateTime(2003, 6, 1).toMoment().format(selectedPattern ?? "L"),
            ),
            WavyDivider(),
          ],
        ),
      ),
      trailing: ModalOverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: pop,
            icon: const Icon(Symbols.check_rounded),
            label: Text("general.done".t(context)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children:
              SelectDateFormat.patterns
                  .map(
                    (pattern) => RadioListTile<String?>(
                      title: Text(pattern),
                      subtitle: Text(
                        DateTime(2025, 8, 22).toMoment().format(pattern),
                      ),
                      value: pattern,
                      groupValue: selectedPattern,
                      onChanged: (value) {
                        setState(() {
                          selectedPattern = value;
                        });
                      },
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  void pop() {
    context.pop<String>(selectedPattern);
  }
}
