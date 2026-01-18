package test.shipping;

import org.json.JSONObject;
import app.usecase.shipping.CreateShippingInput;
import app.usecase.shipping.CreateShippingResult;

public final class CreateShippingRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        CreateShippingInput input = new CreateShippingInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        CreateShippingResult result = CreateShippingResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: CreateShippingRpcTest");
    }
}
