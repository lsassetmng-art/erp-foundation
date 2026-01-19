package app.repository.impl.auth;

import org.json.JSONObject;
import foundation.supabase.SupabaseRpcClient;
import app.repository.LogoutUserRepository;

public final class LogoutUserRepositoryImpl implements LogoutUserRepository {

    @Override
    public Object call(Object input) throws Exception {
        JSONObject params = new JSONObject();
        // TODO: input → params mapping（company_id 禁止）

        return SupabaseRpcClient.call(
            "rpc_auth_logoutuser",
            params
        );
    }
}
