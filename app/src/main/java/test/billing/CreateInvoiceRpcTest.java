package test.billing;

import org.json.JSONObject;
import app.usecase.billing.CreateInvoiceInput;
import app.usecase.billing.CreateInvoiceResult;

public final class CreateInvoiceRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        CreateInvoiceInput input = new CreateInvoiceInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        CreateInvoiceResult result = CreateInvoiceResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: CreateInvoiceRpcTest");
    }
}
