package app.ui;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import app.activity.order.GetOrderListActivity;

@RunWith(AndroidJUnit4.class)
public class GetOrderListActivityTest {

    @Rule
    public ActivityTestRule<GetOrderListActivity> rule = new ActivityTestRule<>(GetOrderListActivity.class);

    @Test
    public void launch_should_succeed() {
        // 入力→実行がクラッシュしないこと
        // Espresso 操作は依存追加後に有効化
        
    }
}
