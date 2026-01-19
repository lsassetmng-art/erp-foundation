package app.usecase.auth;

import org.json.JSONObject;

public final class AuthenticateUserInput {

  public AuthenticateUserInput() {
  }

  public JSONObject toJson() {
    JSONObject o = new JSONObject();
    return o;
  }
}
