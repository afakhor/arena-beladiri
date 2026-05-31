package com.example.arena_beladiri; // Sesuaikan dengan paket bawaan file

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.widget.RemoteViews;

// --- TAMBAHKAN BARIS IMPORT KRITIS INI ---
import com.bskrwingchun.hpki.R; 
// -----------------------------------------

public class MyWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            // Sekarang sistem tahu persis letak R.layout.widget_layout berada!
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_layout);
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}