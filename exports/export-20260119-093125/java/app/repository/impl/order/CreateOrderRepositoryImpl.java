package app.repository.impl.order;

import org.json.JSONObject;
import foundation.supabase.SupabaseRpcClient;
import app.repository.CreateOrderRepository;

public final class CreateOrderRepositoryImpl implements CreateOrderRepository {

    @Override
    public Object call(Object input) throws Exception {
        JSONObject params = new JSONObject();
        // TODO: input → params mapping（company_id 禁止）

        return SupabaseRpcClient.call(
            "rpc_order_createorder",
            params
        );
    }
}
