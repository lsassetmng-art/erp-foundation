package app.ui.viewmodel;

import java.util.regex.Pattern;

public final class LoginViewModel extends BaseViewModel {

    public LoginViewModel(UiCallbacks ui) {
        super(ui);
    }

    public void submit(final Input input) {
        executeSafe(() -> {
            validate(input);
            // TODO: call UseCase here (wire later)
            ui.onSuccess();
        });
    }

    private void validate(Input input) {

        // メール
        if (input.email == null) input.email = "";
        if (input.email.trim().isEmpty()) {
            ui.onValidationError("email", "メールは必須です");
            throw new IllegalArgumentException("メールは必須です");
        }
        if (!input.email.trim().isEmpty() && input.email.length() < 5) {
            ui.onValidationError("email", "メールは5文字以上です");
            throw new IllegalArgumentException("メールは5文字以上です");
        }
        if (input.email.length() > 254) {
            ui.onValidationError("email", "メールは254文字以内です");
            throw new IllegalArgumentException("メールは254文字以内です");
        }
        if (!input.email.trim().isEmpty() && !Pattern.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", input.email.trim())) {
            ui.onValidationError("email", "メールの形式が不正です");
            throw new IllegalArgumentException("メールの形式が不正です");
        }
        // パスワード
        if (input.password == null) input.password = "";
        if (input.password.trim().isEmpty()) {
            ui.onValidationError("password", "パスワードは必須です");
            throw new IllegalArgumentException("パスワードは必須です");
        }
        if (!input.password.trim().isEmpty() && input.password.length() < 8) {
            ui.onValidationError("password", "パスワードは8文字以上です");
            throw new IllegalArgumentException("パスワードは8文字以上です");
        }
        if (input.password.length() > 64) {
            ui.onValidationError("password", "パスワードは64文字以内です");
            throw new IllegalArgumentException("パスワードは64文字以内です");
        }
    }

    public static final class Input {
        public String email;
        public String password;
    }
}
