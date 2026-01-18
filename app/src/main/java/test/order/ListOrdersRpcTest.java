package test.order;

import org.json.JSONObject;
import app.usecase.order.ListOrdersInput;
import app.usecase.order.ListOrdersResult;

public final class ListOrdersRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        ListOrdersInput input = new ListOrdersInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        ListOrdersResult result = ListOrdersResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: ListOrdersRpcTest");
    }
}
