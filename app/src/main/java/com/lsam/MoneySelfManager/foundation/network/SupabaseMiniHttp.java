package com.lsam.MoneySelfManager.foundation.network;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public final class SupabaseMiniHttp {

    // TODO: 既存の SupabaseConfig があるならそちらへ寄せてOK
    public static String SUPABASE_URL = "";     // 例: https://xxxxx.supabase.co
    public static String SUPABASE_ANON_KEY = ""; // anon key

    private static String readAll(InputStream in) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(in));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
        return sb.toString();
    }

    public static JSONObject postJson(String path, JSONObject body, String bearer) throws Exception {
        URL url = new URL(SUPABASE_URL + path);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/json");
        con.setRequestProperty("apikey", SUPABASE_ANON_KEY);
        if (bearer != null && !bearer.isEmpty()) con.setRequestProperty("Authorization", "Bearer " + bearer);
        con.setDoOutput(true);

        try (OutputStream os = con.getOutputStream()) {
            os.write(body.toString().getBytes("UTF-8"));
        }

        int code = con.getResponseCode();
        InputStream in = (code >= 200 && code < 300) ? con.getInputStream() : con.getErrorStream();
        String text = readAll(in);
        JSONObject res = new JSONObject();
        res.put("_http_code", code);
        res.put("_body", text);
        return res;
    }
}
