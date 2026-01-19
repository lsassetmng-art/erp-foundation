package foundation.repository;

import org.json.JSONObject;
import app.usecase.order.CreateOrderInput;
import app.usecase.order.CreateOrderResult;
import app.usecase.order.CreateOrderRepository;

public final class RpcCreateOrderRepository
        extends RpcRepository
        implements CreateOrderRepository {

    @Override
    public CreateOrderResult call(CreateOrderInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return CreateOrderResult.fromJson(res);
    }
}
