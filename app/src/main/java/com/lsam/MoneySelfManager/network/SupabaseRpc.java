package com.lsam.MoneySelfManager.network;

import org.json.JSONObject;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Scanner;

/**
 * 最小RPCクライアント（public RPC専用）
 * 必須：SUPABASE_URL / SUPABASE_ANON_KEY をどこかで供給すること
 */
public class SupabaseRpc {

    public static String SUPABASE_URL = "";     // 例: https://xxxxx.supabase.co
    public static String ANON_KEY = "";         // anon key

    public static String postJson(String path, JSONObject body) throws Exception {
        URL url = new URL(SUPABASE_URL + path);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("apikey", ANON_KEY);
        conn.setRequestProperty("Authorization", "Bearer " + ANON_KEY);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        byte[] bytes = body.toString().getBytes("UTF-8");
        OutputStream os = conn.getOutputStream();
        os.write(bytes);
        os.close();

        int code = conn.getResponseCode();
        Scanner sc = new Scanner((code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream(), "UTF-8");
        StringBuilder sb = new StringBuilder();
        while (sc.hasNextLine()) sb.append(sc.nextLine());
        sc.close();

        if (code < 200 || code >= 300) {
            throw new RuntimeException("HTTP " + code + " " + sb);
        }
        return sb.toString();
    }
}
