package app.usecase.auth;

import org.json.JSONObject;

public final class LogoutUserResult {

  public static LogoutUserResult fromJson(JSONObject o) {
    LogoutUserResult r = new LogoutUserResult();
    return r;
  }
}
