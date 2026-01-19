package foundation.repository;

import org.json.JSONObject;
import app.usecase.order.GetOrderListInput;
import app.usecase.order.GetOrderListResult;
import app.usecase.order.GetOrderListRepository;

public final class RpcGetOrderListRepository
        extends RpcRepository
        implements GetOrderListRepository {

    @Override
    public GetOrderListResult call(GetOrderListInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return GetOrderListResult.fromJson(res);
    }
}
