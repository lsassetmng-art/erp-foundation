package app.activity.order;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

public final class ListOrdersActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // setContentView(R.layout.activity_listorders);
    
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
                    ListOrdersInput input = new ListOrdersInput();
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
