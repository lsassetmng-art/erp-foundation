package app.ui.viewmodel;

import java.util.regex.Pattern;

public final class CreateShippingViewModel extends BaseViewModel {

    public CreateShippingViewModel(UiCallbacks ui) {
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

        // 出荷番号
        if (input.shipping_no == null) input.shipping_no = "";
        if (input.shipping_no.trim().isEmpty()) {
            ui.onValidationError("shipping_no", "出荷番号は必須です");
            throw new IllegalArgumentException("出荷番号は必須です");
        }
        if (!input.shipping_no.trim().isEmpty() && input.shipping_no.length() < 1) {
            ui.onValidationError("shipping_no", "出荷番号は1文字以上です");
            throw new IllegalArgumentException("出荷番号は1文字以上です");
        }
        if (input.shipping_no.length() > 30) {
            ui.onValidationError("shipping_no", "出荷番号は30文字以内です");
            throw new IllegalArgumentException("出荷番号は30文字以内です");
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
        public String shipping_no;
        public String order_no;
    }
}
