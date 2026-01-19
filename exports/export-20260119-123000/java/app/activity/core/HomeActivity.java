package app.activity.core;

import android.os.Bundle;
import android.widget.Button;
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
        
        // XML-DTO-WIRED
        EditText et = findViewById(R.id.input_text);
        Button btn = findViewById(R.id.btn_execute);
        if (btn != null && et != null) {
            btn.setOnClickListener(v -> {
                try {
                    HomeInput input = new HomeInput();
                    input.setValue(et.getText().toString());
                    // TODO: ViewModel.execute(input)
                
        // XML-VM-WIRED
        Button btn = findViewById(R.id.btn_execute);
        if (btn != null) {
            btn.setOnClickListener(v -> {
                // TODO: ViewModel.execute(input) を呼ぶ
            });
        }

} catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }

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
