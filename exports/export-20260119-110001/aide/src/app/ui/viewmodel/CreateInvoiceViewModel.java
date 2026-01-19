package app.ui.viewmodel;

import java.util.regex.Pattern;

public final class CreateInvoiceViewModel extends BaseViewModel {

    public CreateInvoiceViewModel(UiCallbacks ui) {
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

        // 請求番号
        if (input.billing_no == null) input.billing_no = "";
        if (input.billing_no.trim().isEmpty()) {
            ui.onValidationError("billing_no", "請求番号は必須です");
            throw new IllegalArgumentException("請求番号は必須です");
        }
        if (!input.billing_no.trim().isEmpty() && input.billing_no.length() < 1) {
            ui.onValidationError("billing_no", "請求番号は1文字以上です");
            throw new IllegalArgumentException("請求番号は1文字以上です");
        }
        if (input.billing_no.length() > 30) {
            ui.onValidationError("billing_no", "請求番号は30文字以内です");
            throw new IllegalArgumentException("請求番号は30文字以内です");
        }
        // 受注番号
        if (input.order_no == null) input.order_no = "";
        if (input.order_no.trim().isEmpty()) {
            ui.onValidationError("order_no", "受注番号は必須です");
            throw new IllegalArgumentException("受注番号は必須です");
        }
        if (!input.order_no.trim().isEmpty() && input.order_no.length() < 1) {
            ui.onValidationError("order_no", "受注番号は1文字以上です");
            throw new IllegalArgumentException("受注番号は1文字以上です");
        }
        if (input.order_no.length() > 30) {
            ui.onValidationError("order_no", "受注番号は30文字以内です");
            throw new IllegalArgumentException("受注番号は30文字以内です");
        }
    }

    public static final class Input {
        public String billing_no;
        public String order_no;
    }
}
