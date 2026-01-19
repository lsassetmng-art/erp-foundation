package app.usecase.order;

import org.json.JSONObject;

public final class ListOrdersResult {

  public static ListOrdersResult fromJson(JSONObject o) {
    ListOrdersResult r = new ListOrdersResult();
    return r;
  }
}
