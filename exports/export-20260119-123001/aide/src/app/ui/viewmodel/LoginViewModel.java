package app.ui.viewmodel;

public class LoginViewModel extends BaseViewModel {

    public void submit(Input input) {
        executeSafe(() -> {
            if (input.email == null || input.email.toString().isEmpty())
                throw new IllegalArgumentException("email is required");
            if (input.password == null || input.password.toString().isEmpty())
                throw new IllegalArgumentException("password is required");
            if (input.password.length() < 8)
                throw new IllegalArgumentException("password too short");
        });
    }

    public static class Input {
        public String email;
        public String password;
    }
}