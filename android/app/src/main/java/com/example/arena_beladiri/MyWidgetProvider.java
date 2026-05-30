package com.example.arena_beladiri;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.widget.RemoteViews;

public class MyWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            // Menghubungkan ke layout dashboard (XML) yang Coach buat tadi
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_layout);
            
            // Nantinya di sini kita masukkan logika pengiriman grafik dari Flutter
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}