package test.order;

import org.json.JSONObject;
import app.usecase.order.CreateOrderInput;
import app.usecase.order.CreateOrderResult;

public final class CreateOrderRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        CreateOrderInput input = new CreateOrderInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        CreateOrderResult result = CreateOrderResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: CreateOrderRpcTest");
    }
}
