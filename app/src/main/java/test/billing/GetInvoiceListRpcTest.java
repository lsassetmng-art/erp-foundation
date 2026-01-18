package test.billing;

import org.json.JSONObject;
import app.usecase.billing.GetInvoiceListInput;
import app.usecase.billing.GetInvoiceListResult;

public final class GetInvoiceListRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        GetInvoiceListInput input = new GetInvoiceListInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        GetInvoiceListResult result = GetInvoiceListResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: GetInvoiceListRpcTest");
    }
}
