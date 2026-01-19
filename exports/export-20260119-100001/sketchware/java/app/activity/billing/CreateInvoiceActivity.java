package app.activity.billing;
import app.viewmodel.billing.CreateInvoiceViewModel;
import app.dto.billing.CreateInvoiceInput;
import android.widget.Toast;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

public final class CreateInvoiceActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // setContentView(R.layout.activity_createinvoice);
    
        
        // AUTO_BIND_FROM_SPEC
        final CreateInvoiceViewModel vm = new CreateInvoiceViewModel(null);
        Button btn = findViewById(R.id.btn_execute);
        if (btn != null) {
            btn.setOnClickListener(v -> {
                try {
                    CreateInvoiceInput input = new CreateInvoiceInput();
                    EditText et_amount = findViewById(R.id.input_amount);
                    int amount = 0;
                    if (et_amount != null) {
                        String s = et_amount.getText().toString().trim();
                        amount = s.isEmpty() ? 0 : Integer.parseInt(s);
                    }
                    input.setAmount(amount);
                    EditText et_note = findViewById(R.id.input_note);
                    String note = et_note == null ? "" : et_note.getText().toString();
                    input.setNote(note);
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
                    CreateInvoiceInput input = new CreateInvoiceInput();
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
