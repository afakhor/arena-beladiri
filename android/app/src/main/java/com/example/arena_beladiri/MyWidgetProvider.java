package com.example.arena_beladiri;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;

public class MyWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        // Cari ID layout secara dinamis agar tidak error Package Name
        int layoutId = context.getResources().getIdentifier("widget_layout", "layout", context.getPackageName());
        if (layoutId != 0) {
            RemoteViews views = new RemoteViews(context.getPackageName(), layoutId);
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        // Memastikan widget mau refresh saat dipanggil Flutter
    }
}