package foundation.repository;

import org.json.JSONObject;
import app.usecase.billing.GetInvoiceListInput;
import app.usecase.billing.GetInvoiceListResult;
import app.usecase.billing.GetInvoiceListRepository;

public final class RpcGetInvoiceListRepository
        extends RpcRepository
        implements GetInvoiceListRepository {

    @Override
    public GetInvoiceListResult call(GetInvoiceListInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return GetInvoiceListResult.fromJson(res);
    }
}
