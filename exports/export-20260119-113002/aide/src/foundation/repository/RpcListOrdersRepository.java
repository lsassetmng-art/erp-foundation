package foundation.repository;

import org.json.JSONObject;
import app.usecase.order.ListOrdersInput;
import app.usecase.order.ListOrdersResult;
import app.usecase.order.ListOrdersRepository;

public final class RpcListOrdersRepository
        extends RpcRepository
        implements ListOrdersRepository {

    @Override
    public ListOrdersResult call(ListOrdersInput input) throws Exception {
        JSONObject res = callRpc("rpc_order_list", input.toJson());
        return ListOrdersResult.fromJson(res);
    }
}
