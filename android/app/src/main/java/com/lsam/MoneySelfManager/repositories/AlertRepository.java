package com.lsam.MoneySelfManager.repositories;

import android.content.Context;

import com.lsam.MoneySelfManager.models.AlertRow;
import com.lsam.MoneySelfManager.network.SupabaseRest;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

public final class AlertRepository {

    private AlertRepository(){}

    public static ArrayList<AlertRow> fetchAll(Context ctx) throws Exception {
        ArrayList<AlertRow> out = new ArrayList<>();
        add(out, "返品多発", SupabaseRest.get(ctx, "/rest/v1/v_alert_return_rate?select=*"));
        add(out, "過剰控除", SupabaseRest.get(ctx, "/rest/v1/v_alert_over_return?select=*"));
        add(out, "未請求出荷", SupabaseRest.get(ctx, "/rest/v1/v_alert_unbilled_shipping?select=*"));
        return out;
    }

    private static void add(ArrayList<AlertRow> out, String type, String json) throws Exception {
        JSONArray arr = new JSONArray(json);
        for (int i = 0; i < arr.length(); i++) {
            JSONObject o = arr.getJSONObject(i);
            AlertRow a = new AlertRow();
            a.type = type;
            a.title = type;
            a.body = o.toString();
            out.add(a);
        }
    }
}
