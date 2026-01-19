package app.usecase.billing;

import org.json.JSONObject;

public final class GetInvoiceListResult {

  public static GetInvoiceListResult fromJson(JSONObject o) {
    GetInvoiceListResult r = new GetInvoiceListResult();
    return r;
  }
}
