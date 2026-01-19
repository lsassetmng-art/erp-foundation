package app.usecase.order;

import org.json.JSONObject;

public final class GetOrderListResult {

  public static GetOrderListResult fromJson(JSONObject o) {
    GetOrderListResult r = new GetOrderListResult();
    return r;
  }
}
