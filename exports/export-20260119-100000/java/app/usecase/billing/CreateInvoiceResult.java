package app.usecase.billing;

import org.json.JSONObject;

public final class CreateInvoiceResult {

  public static CreateInvoiceResult fromJson(JSONObject o) {
    CreateInvoiceResult r = new CreateInvoiceResult();
    return r;
  }
}
