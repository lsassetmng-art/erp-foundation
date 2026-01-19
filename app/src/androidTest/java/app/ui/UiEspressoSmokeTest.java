
package app.ui;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.matcher.ViewMatchers.isRoot;

@RunWith(AndroidJUnit4.class)
public class UiEspressoSmokeTest {

    @Rule
    public ActivityTestRule<MainActivity> rule =
        new ActivityTestRule<>(MainActivity.class);

    @Test
    public void app_starts() {
        onView(isRoot()).check((v, e) -> {});
    }
}
