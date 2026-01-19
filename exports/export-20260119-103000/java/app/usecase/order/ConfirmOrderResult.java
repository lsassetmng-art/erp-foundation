package app.usecase.order;

import org.json.JSONObject;

public final class ConfirmOrderResult {

  public static ConfirmOrderResult fromJson(JSONObject o) {
    ConfirmOrderResult r = new ConfirmOrderResult();
    return r;
  }
}
