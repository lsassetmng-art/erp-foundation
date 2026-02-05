package com.lsam.MoneySelfManager.repositories;

import android.content.Context;

import com.lsam.MoneySelfManager.models.SalesNetRow;
import com.lsam.MoneySelfManager.network.SupabaseRest;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

public final class SalesNetRepository {

    private SalesNetRepository(){}

    public static ArrayList<SalesNetRow> fetchLatest(Context ctx, int limit) throws Exception {
        if (limit <= 0) limit = 100;
        String path = "/rest/v1/v_sales_net?select=*&order=billing_date.desc&limit=" + limit;
        String res = SupabaseRest.get(ctx, path);

        JSONArray arr = new JSONArray(res);
        ArrayList<SalesNetRow> list = new ArrayList<>();

        for (int i = 0; i < arr.length(); i++) {
            JSONObject o = arr.getJSONObject(i);
            SalesNetRow r = new SalesNetRow();

            r.company_id = o.optString("company_id");
            r.billing_id = o.optLong("billing_id");
            r.billing_no = o.optString("billing_no");
            r.billing_date = o.optString("billing_date");
            r.item_id = o.optLong("item_id");

            r.billed_qty = o.optDouble("billed_qty");
            r.returned_qty = o.optDouble("returned_qty");
            r.net_qty = o.optDouble("net_qty");

            r.unit_price = o.optDouble("unit_price");
            r.gross_amount = o.optDouble("gross_amount");
            r.return_amount = o.optDouble("return_amount");
            r.net_amount = o.optDouble("net_amount");

            list.add(r);
        }
        return list;
    }
}
