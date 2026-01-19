package foundation.repository;

import org.json.JSONObject;
import app.usecase.order.ConfirmOrderInput;
import app.usecase.order.ConfirmOrderResult;
import app.usecase.order.ConfirmOrderRepository;

public final class RpcConfirmOrderRepository
        extends RpcRepository
        implements ConfirmOrderRepository {

    @Override
    public ConfirmOrderResult call(ConfirmOrderInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return ConfirmOrderResult.fromJson(res);
    }
}
