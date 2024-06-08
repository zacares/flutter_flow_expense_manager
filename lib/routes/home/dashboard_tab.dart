import 'package:flow/data/flow_icon.dart';
import 'package:flow/widgets/action_card.dart';
import 'package:flow/widgets/general/flow_icon.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlowIcon(
                          FlowIconData.icon(Symbols.category_rounded),
                          size: 40.0,
                          plated: true,
                        ),
                        const Text("Categories"),
                        const Align(
                          alignment: Alignment.topRight,
                          child: Icon(Symbols.arrow_right_rounded),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ActionCard(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlowIcon(
                          FlowIconData.icon(Symbols.category_rounded),
                          size: 40.0,
                          plated: true,
                        ),
                        const Text("Categories"),
                        const Align(
                          alignment: Alignment.topRight,
                          child: Icon(Symbols.arrow_right_rounded),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
