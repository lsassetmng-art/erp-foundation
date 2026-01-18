package test.order;

import org.json.JSONObject;
import app.usecase.order.GetOrderListInput;
import app.usecase.order.GetOrderListResult;

public final class GetOrderListRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        GetOrderListInput input = new GetOrderListInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        GetOrderListResult result = GetOrderListResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: GetOrderListRpcTest");
    }
}
