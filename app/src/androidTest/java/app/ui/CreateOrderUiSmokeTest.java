package app.ui;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class CreateOrderUiSmokeTest {
    @Test
    public void layout_should_exist_compile_time() {
        // Smoke: just reference R to ensure resources exist.
        int id = app.R.layout.fragment_createorder;
        int btn = app.R.id.btn_submit;
        // no-op
    }
}
