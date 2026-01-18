package test.auth;

import org.json.JSONObject;
import app.usecase.auth.LogoutInput;
import app.usecase.auth.LogoutResult;

public final class LogoutRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        LogoutInput input = new LogoutInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        LogoutResult result = LogoutResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: LogoutRpcTest");
    }
}
