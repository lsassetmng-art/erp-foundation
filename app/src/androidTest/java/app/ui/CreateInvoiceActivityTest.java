package app.ui;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import app.activity.billing.CreateInvoiceActivity;

@RunWith(AndroidJUnit4.class)
public class CreateInvoiceActivityTest {

    @Rule
    public ActivityTestRule<CreateInvoiceActivity> rule = new ActivityTestRule<>(CreateInvoiceActivity.class);

    @Test
    public void launch_should_succeed() {
        // 入力→実行がクラッシュしないこと
        // Espresso 操作は依存追加後に有効化
        
    }
}
