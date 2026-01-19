package app.usecase.order;

import org.json.JSONObject;

public final class CreateOrderResult {

  public static CreateOrderResult fromJson(JSONObject o) {
    CreateOrderResult r = new CreateOrderResult();
    return r;
  }
}
