package com.heruwingchun.hpki; // Wajib sama dengan Bundle ID di Workflow

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;

public class MyWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            int layoutId = context.getResources().getIdentifier("widget_layout", "layout", context.getPackageName());
            if (layoutId != 0) {
                RemoteViews views = new RemoteViews(context.getPackageName(), layoutId);
                appWidgetManager.updateAppWidget(appWidgetId, views);
            }
        }
    }
}