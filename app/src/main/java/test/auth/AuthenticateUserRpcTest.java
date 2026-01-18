package test.auth;

import org.json.JSONObject;
import app.usecase.auth.AuthenticateUserInput;
import app.usecase.auth.AuthenticateUserResult;

public final class AuthenticateUserRpcTest {

    public static void main(String[] args) {
        // ---- Input mock ----
        AuthenticateUserInput input = new AuthenticateUserInput(

        );

        JSONObject json = input.toJson();
        System.out.println("INPUT JSON = " + json);

        // ---- Output mock ----
        JSONObject out = new JSONObject();

        AuthenticateUserResult result = AuthenticateUserResult.fromJson(out);
        System.out.println("RESULT JSON = " + result.toJson());

        System.out.println("OK: AuthenticateUserRpcTest");
    }
}
