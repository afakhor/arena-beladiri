package com.example.arena_beladiri;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.widget.RemoteViews;

public class MyWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            // CARA DINAMIS: Mencari layout tanpa perlu file R
            int layoutId = context.getResources().getIdentifier("widget_layout", "layout", context.getPackageName());
            
            if (layoutId != 0) {
                RemoteViews views = new RemoteViews(context.getPackageName(), layoutId);
                appWidgetManager.updateAppWidget(appWidgetId, views);
            }
        }
    }
}