package test.order;

import org.json.JSONObject;
import app.usecase.order.ConfirmOrderInput;
import app.usecase.order.ConfirmOrderResult;

public final class ConfirmOrderRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        ConfirmOrderInput input = new ConfirmOrderInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        ConfirmOrderResult result = ConfirmOrderResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: ConfirmOrderRpcTest");
    }
}
