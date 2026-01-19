package app.usecase.shipping;

import org.json.JSONObject;

public final class CreateShippingResult {

  public static CreateShippingResult fromJson(JSONObject o) {
    CreateShippingResult r = new CreateShippingResult();
    return r;
  }
}
