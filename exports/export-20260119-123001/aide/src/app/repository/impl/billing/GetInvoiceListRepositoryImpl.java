package app.repository.impl.billing;

import org.json.JSONObject;
import foundation.supabase.SupabaseRpcClient;
import app.repository.GetInvoiceListRepository;

public final class GetInvoiceListRepositoryImpl implements GetInvoiceListRepository {

    @Override
    public Object call(Object input) throws Exception {
        JSONObject params = new JSONObject();
        // TODO: input → params mapping（company_id 禁止）

        return SupabaseRpcClient.call(
            "rpc_billing_getinvoicelist",
            params
        );
    }
}
