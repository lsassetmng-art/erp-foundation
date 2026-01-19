package foundation.repository;

import org.json.JSONObject;
import app.usecase.shipping.CreateShippingInput;
import app.usecase.shipping.CreateShippingResult;
import app.usecase.shipping.CreateShippingRepository;

public final class RpcCreateShippingRepository
        extends RpcRepository
        implements CreateShippingRepository {

    @Override
    public CreateShippingResult call(CreateShippingInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return CreateShippingResult.fromJson(res);
    }
}
