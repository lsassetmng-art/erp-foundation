package foundation.repository;

import org.json.JSONObject;
import app.usecase.billing.CreateInvoiceInput;
import app.usecase.billing.CreateInvoiceResult;
import app.usecase.billing.CreateInvoiceRepository;

public final class RpcCreateInvoiceRepository
        extends RpcRepository
        implements CreateInvoiceRepository {

    @Override
    public CreateInvoiceResult call(CreateInvoiceInput input) throws Exception {
        JSONObject res = callRpc("", input.toJson());
        return CreateInvoiceResult.fromJson(res);
    }
}
