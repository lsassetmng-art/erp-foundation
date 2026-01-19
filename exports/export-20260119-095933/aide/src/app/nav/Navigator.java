package app.nav;

import android.content.Context;
import android.content.Intent;

public final class Navigator {
  private Navigator() {}

  public static Intent intent(Context ctx, String route) {
    switch (route) {
      case Routes.AUTH_AUTHENTICATEUSERACTIVITY: return new Intent(ctx, app.activity.auth.AuthenticateUserActivity.class);
      case Routes.AUTH_LOGOUTACTIVITY: return new Intent(ctx, app.activity.auth.LogoutActivity.class);
      case Routes.AUTH_LOGOUTUSERACTIVITY: return new Intent(ctx, app.activity.auth.LogoutUserActivity.class);
      case Routes.BILLING_CREATEINVOICEACTIVITY: return new Intent(ctx, app.activity.billing.CreateInvoiceActivity.class);
      case Routes.BILLING_GETINVOICELISTACTIVITY: return new Intent(ctx, app.activity.billing.GetInvoiceListActivity.class);
      case Routes.ORDER_CONFIRMORDERACTIVITY: return new Intent(ctx, app.activity.order.ConfirmOrderActivity.class);
      case Routes.ORDER_CREATEORDERACTIVITY: return new Intent(ctx, app.activity.order.CreateOrderActivity.class);
      case Routes.ORDER_GETORDERLISTACTIVITY: return new Intent(ctx, app.activity.order.GetOrderListActivity.class);
      case Routes.ORDER_LISTORDERSACTIVITY: return new Intent(ctx, app.activity.order.ListOrdersActivity.class);
      case Routes.ORDER_ORDERACTIVITY: return new Intent(ctx, app.activity.order.OrderActivity.class);
      case Routes.SHIPPING_CREATESHIPPINGACTIVITY: return new Intent(ctx, app.activity.shipping.CreateShippingActivity.class);
      default: throw new IllegalArgumentException("Unknown route: " + route);
    }
  }
}
