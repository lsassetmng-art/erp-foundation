package app.repository.impl.shipping;

import org.json.JSONObject;
import foundation.supabase.SupabaseRpcClient;
import app.repository.CreateShippingRepository;

public final class CreateShippingRepositoryImpl implements CreateShippingRepository {

    @Override
    public Object call(Object input) throws Exception {
        JSONObject params = new JSONObject();
        // TODO: input → params mapping（company_id 禁止）

        return SupabaseRpcClient.call(
            "rpc_shipping_createshipping",
            params
        );
    }
}
