package foundation.network;

import org.json.JSONObject;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import foundation.session.SessionManager;

/**
 * RpcClient
 *
 * - Supabase RPC 呼び出し専用
 * - Authorization ヘッダは SessionManager から取得
 */
public final class RpcClient {

    private static final String BASE_URL =
            "https://YOUR_PROJECT_ID.supabase.co/rest/v1/rpc/";

    public static JSONObject post(String action, JSONObject payload) throws Exception {
        URL url = new URL(BASE_URL + action);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty(
                "Authorization",
                "Bearer " + SessionManager.getInstance().getAccessToken()
        );
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(payload.toString().getBytes("UTF-8"));
        }

        if (conn.getResponseCode() >= 400) {
            throw new RuntimeException("RPC error: " + conn.getResponseCode());
        }

        return new JSONObject(); // 実装段階では mock / 将来差し替え
    }
}
