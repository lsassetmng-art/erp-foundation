package foundation.supabase;

import org.json.JSONObject;

public final class SupabaseRpcClient {

    private SupabaseRpcClient() {}

    public static JSONObject call(String rpcName, JSONObject params) {
        if (params != null && params.toString().contains("company_id")) {
            throw new IllegalStateException("Forbidden: company_id in RPC params");
        }

        // 実装は後続（HTTP / SDK）
        // ここではスタブとして返す
        return new JSONObject();
    }
}
