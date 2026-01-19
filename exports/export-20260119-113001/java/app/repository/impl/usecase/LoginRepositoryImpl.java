package app.repository.impl.usecase;

import org.json.JSONObject;
import foundation.supabase.SupabaseRpcClient;
import app.repository.LoginRepository;

public final class LoginRepositoryImpl implements LoginRepository {

    @Override
    public Object call(Object input) throws Exception {
        JSONObject params = new JSONObject();
        // TODO: input → params mapping（company_id 禁止）

        return SupabaseRpcClient.call(
            "rpc_usecase_login",
            params
        );
    }
}
