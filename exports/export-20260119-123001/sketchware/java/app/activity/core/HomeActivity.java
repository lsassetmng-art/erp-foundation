package app.activity.core;

import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import androidx.appcompat.app.AppCompatActivity;

import app.nav.Navigator;

public final class HomeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        ListView list = findViewById(R.id.list_routes);
        String[] routes = new String[] {
            "auth/AuthenticateUserActivity",
            "auth/LogoutActivity",
            "auth/LogoutUserActivity",
            "billing/CreateInvoiceActivity",
            "billing/GetInvoiceListActivity",
            "order/ConfirmOrderActivity",
            "order/CreateOrderActivity",
            "order/GetOrderListActivity",
            "order/ListOrdersActivity",
            "order/OrderActivity",
            "shipping/CreateShippingActivity"
        };

        ArrayAdapter<String> adapter =
                new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, routes);
        list.setAdapter(adapter);

        list.setOnItemClickListener((parent, view, pos, id) -> {
            String route = routes[pos];
            startActivity(Navigator.intent(this, route));
        });
    }
}
