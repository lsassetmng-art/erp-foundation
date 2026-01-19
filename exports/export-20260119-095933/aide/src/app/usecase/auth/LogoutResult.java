package app.usecase.auth;

import org.json.JSONObject;

public final class LogoutResult {

  public static LogoutResult fromJson(JSONObject o) {
    LogoutResult r = new LogoutResult();
    return r;
  }
}
