package app.repository.impl.order;

import org.json.JSONObject;
import foundation.supabase.SupabaseRpcClient;
import app.repository.ConfirmOrderRepository;

public final class ConfirmOrderRepositoryImpl implements ConfirmOrderRepository {

    @Override
    public Object call(Object input) throws Exception {
        JSONObject params = new JSONObject();
        // TODO: input → params mapping（company_id 禁止）

        return SupabaseRpcClient.call(
            "rpc_order_confirmorder",
            params
        );
    }
}
