package mn.flow.flow.widgets

import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.components.CircleIconButton
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview
import androidx.glance.state.GlanceStateDefinition
import mn.flow.flow.R

class TwoEntry : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                Content()
            }
        }
    }
}

private val defaultOrder = listOf(
    "income",
    "expense",
)

private fun getButtonOrder(context: Context): List<String> {
    val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    var buttonOrder =
        prefs.getString("flutter.flow.widgets.buttonOrder", null)?.split(",")
            ?: defaultOrder

    print(buttonOrder)

    if (!buttonOrder.containsAll(defaultOrder)) {
        buttonOrder = defaultOrder
    }

    return buttonOrder.filter { item -> item != "transfer" }
}

@OptIn(ExperimentalGlancePreviewApi::class)
@Composable
@Preview
private fun Content() {
    val buttonOrder = getButtonOrder(LocalContext.current)

    Box(modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground)) {
        Row(
            modifier = GlanceModifier.fillMaxSize()
                .padding(start = 12.dp, top = 12.dp, bottom = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            buttonOrder.forEach { operation ->
                CircleIconButton(
                    ImageProvider(if (operation == "expense") R.drawable.expense else R.drawable.income),
                    backgroundColor = GlanceTheme.colors.primary,
                    contentColor = GlanceTheme.colors.widgetBackground,
                    contentDescription = "New ${operation.capitalize()}",
                    onClick =
                        actionStartActivity(
                            Intent(
                                Intent.ACTION_VIEW,
                                "flow-mn:///transaction/new?type=${operation}".toUri()
                            )
                        )
                )
                Spacer(GlanceModifier.padding(end = 12.dp))
            }
        }
    }
}
