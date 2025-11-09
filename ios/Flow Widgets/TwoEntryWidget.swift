import SwiftUI
import WidgetKit

struct TwoEntryWidgetEntry: TimelineEntry {
    let date: Date
    let order: [String]
    let color: Color
}

struct TwoEntryProvider: AppIntentTimelineProvider {
    typealias Entry = TwoEntryWidgetEntry

    typealias Intent = ConfigurationAppIntent

    func placeholder(in context: Context) -> TwoEntryWidgetEntry {
        TwoEntryWidgetEntry(date: Date(), order: ["income", "expense"], color: .primary)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async
        -> TwoEntryWidgetEntry
    {
        TwoEntryWidgetEntry(date: Date(), order: ["income", "expense"], color: .primary)
    }

    static let validOrderNames: [String] = ["income", "expense", "transfer"]

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
        TwoEntryWidgetEntry
    > {
        let order: [String] =
            UserDefaults.standard.string(forKey: "flow.widgets.buttonOrder")?.split(separator: ",") ?? [
                "income", "expense",
            ].joined(separator: ",")
        let colorHex: String? = UserDefaults.standard.string(forKey: "flow.widgets.color")
        let validOrder: [String] =
            (order.allSatisfy({ TwoEntryProvider.validOrderNames.contains($0) })
                && order.count >= 2)
            ? order : ["income", "expense"]

        let entry = TwoEntryWidgetEntry(date: Date(), order: validOrder, color: .primary)

        return Timeline(entries: [entry], policy: .atEnd)
    }

    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct TwoEntryWidgetView: View {
    var entry: TwoEntryWidgetEntry

    static let spacing = 8.0

    var body: some View {
        GeometryReader { geometry in
            let size = (geometry.size.height - 40) * 0.5

            VStack(alignment: .center, spacing: TwoEntryWidgetView.spacing) {
                Link(destination: URL(string: "flow-mn:///transaction/new?type=transfer")!) {
                    Capsule()
                    .fill(.tertiary)
                    .overlay{
                        Image("Transfer")
                            .resizable()
                            .foregroundStyle(.primary)
                            .frame(
                                width: size,
                                height: size)
                    }
                }
                HStack(spacing: TwoEntryWidgetView.spacing) {
                    ForEach(entry.order.filter({ $0 != "transfer" }), id: \.self) { item in
                        Link(destination: URL(string: "flow-mn:///transaction/new?type=\(item)")!) {
                            Circle()
                                .fill(.tertiary)
                                .overlay {
                                    Image(item.capitalized)
                                        .resizable()
                                        .foregroundStyle(.primary)
                                        .frame(
                                            width: size,
                                            height: size)
                                }
                        }
                    }
                }
            }
        }
    }
}

struct FlowTwoEntryWidget: Widget {
    let kind: String = "FlowTwoEntryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: ConfigurationAppIntent.self, provider: TwoEntryProvider()
        ) { entry in
            TwoEntryWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall])

    }
}

#Preview(as: .systemSmall) {
    FlowTwoEntryWidget()
} timeline: {
    TwoEntryWidgetEntry(date: .now, order: ["income", "expense"], color: .primary)
}
