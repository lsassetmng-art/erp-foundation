package app.activity.order;
import app.viewmodel.order.CreateOrderViewModel;
import app.dto.order.CreateOrderInput;
import android.widget.Toast;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

public final class CreateOrderActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // setContentView(R.layout.activity_createorder);
    
        
        // AUTO_BIND_FROM_SPEC
        final CreateOrderViewModel vm = new CreateOrderViewModel(null);
        Button btn = findViewById(R.id.btn_execute);
        if (btn != null) {
            btn.setOnClickListener(v -> {
                try {
                    CreateOrderInput input = new CreateOrderInput();
                    EditText et_value = findViewById(R.id.input_value);
                    String value = et_value == null ? "" : et_value.getText().toString();
                    input.setValue(value);
                    EditText et_quantity = findViewById(R.id.input_quantity);
                    int quantity = 0;
                    if (et_quantity != null) {
                        String s = et_quantity.getText().toString().trim();
                        quantity = s.isEmpty() ? 0 : Integer.parseInt(s);
                    }
                    input.setQuantity(quantity);
                    vm.executeSafe(input);
                } catch (IllegalArgumentException e) {
                    Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }
// XML-VM-WIRED
        Button btn = findViewById(R.id.btn_execute);
        if (btn != null) {
            btn.setOnClickListener(v -> {
                // TODO: ViewModel.execute(input) を呼ぶ
            
        // XML-DTO-WIRED
        EditText et = findViewById(R.id.input_text);
        Button btn = findViewById(R.id.btn_execute);
        if (btn != null && et != null) {
            btn.setOnClickListener(v -> {
                try {
                    CreateOrderInput input = new CreateOrderInput();
                    input.setValue(et.getText().toString());
                    // TODO: ViewModel.execute(input)
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }

});
        }

}
}
