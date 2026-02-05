package com.lsam.MoneySelfManager.network;

import android.content.Context;
import android.content.SharedPreferences;

import com.lsam.MoneySelfManager.R;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public final class SupabaseRest {

    private SupabaseRest(){}

    public static String get(Context ctx, String pathAndQuery) throws Exception {
        String base = ctx.getString(R.string.supabase_url).trim();
        String anon = ctx.getString(R.string.supabase_anon_key).trim();
        if (base.isEmpty() || anon.isEmpty()) {
            throw new IllegalStateException("supabase_url / supabase_anon_key is empty (res/values/supabase_sales.xml)");
        }

        String url = base + pathAndQuery;
        HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
        con.setRequestMethod("GET");
        con.setConnectTimeout(15000);
        con.setReadTimeout(20000);

        String token = readAccessToken(ctx);
        con.setRequestProperty("apikey", anon);
        con.setRequestProperty("Authorization", "Bearer " + (token.isEmpty() ? anon : token));
        con.setRequestProperty("Accept", "application/json");

        int code = con.getResponseCode();
        BufferedReader br = new BufferedReader(new InputStreamReader(
                (code >= 200 && code < 300) ? con.getInputStream() : con.getErrorStream()
        ));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
        br.close();

        if (code < 200 || code >= 300) {
            throw new RuntimeException("HTTP " + code + " " + sb);
        }
        return sb.toString();
    }

    public static String post(Context ctx, String pathAndQuery, String jsonBody) throws Exception {
        String base = ctx.getString(R.string.supabase_url).trim();
        String anon = ctx.getString(R.string.supabase_anon_key).trim();
        if (base.isEmpty() || anon.isEmpty()) {
            throw new IllegalStateException("supabase_url / supabase_anon_key is empty (res/values/supabase_sales.xml)");
        }

        String url = base + pathAndQuery;
        HttpURLConnection con = (HttpURLConnection) new URL(url).openConnection();
        con.setRequestMethod("POST");
        con.setConnectTimeout(15000);
        con.setReadTimeout(20000);
        con.setDoOutput(true);

        String token = readAccessToken(ctx);
        con.setRequestProperty("apikey", anon);
        con.setRequestProperty("Authorization", "Bearer " + (token.isEmpty() ? anon : token));
        con.setRequestProperty("Content-Type", "application/json");
        con.setRequestProperty("Accept", "application/json");

        OutputStream os = con.getOutputStream();
        os.write(jsonBody.getBytes("UTF-8"));
        os.close();

        int code = con.getResponseCode();
        BufferedReader br = new BufferedReader(new InputStreamReader(
                (code >= 200 && code < 300) ? con.getInputStream() : con.getErrorStream()
        ));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
        br.close();

        if (code < 200 || code >= 300) {
            throw new RuntimeException("HTTP " + code + " " + sb);
        }
        return sb.toString();
    }

    private static String readAccessToken(Context ctx) {
        try {
            SharedPreferences sp = ctx.getSharedPreferences("session", Context.MODE_PRIVATE);
            String t = sp.getString("access_token", "");
            return t == null ? "" : t.trim();
        } catch (Throwable ignore) {
            return "";
        }
    }
}
