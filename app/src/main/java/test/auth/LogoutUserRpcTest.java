package test.auth;

import org.json.JSONObject;
import app.usecase.auth.LogoutUserInput;
import app.usecase.auth.LogoutUserResult;

public final class LogoutUserRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        LogoutUserInput input = new LogoutUserInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        LogoutUserResult result = LogoutUserResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: LogoutUserRpcTest");
    }
}
