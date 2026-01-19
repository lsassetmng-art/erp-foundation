package app.usecase.auth;

import org.json.JSONObject;

public final class AuthenticateUserResult {

  public static AuthenticateUserResult fromJson(JSONObject o) {
    AuthenticateUserResult r = new AuthenticateUserResult();
    return r;
  }
}
