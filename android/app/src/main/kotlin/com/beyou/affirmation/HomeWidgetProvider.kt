package com.beyou.affirmation

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class AffirmationWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.affirmation_widget_layout).apply {
                // Get the affirmation from shared preferences
                val title = widgetData.getString("title", "BeYou")
                val message = widgetData.getString("message", "Be your best self today!")
                
                // Set the text on the TextView
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_message, message)
                
                // Create an intent to launch the app when widget is clicked
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
                
                // Create an intent to update the widget when "titleclicked" is triggered
                val refreshIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    android.net.Uri.parse("homeWidgetTitleClicked://titleclicked")
                )
                setOnClickPendingIntent(R.id.widget_title, refreshIntent)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}