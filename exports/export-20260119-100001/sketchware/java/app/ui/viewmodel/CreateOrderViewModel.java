package app.ui.viewmodel;

import java.util.regex.Pattern;

public final class CreateOrderViewModel extends BaseViewModel {

    public CreateOrderViewModel(UiCallbacks ui) {
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
        // 数量
        if (input.qty == null) {
            ui.onValidationError("qty", "数量は必須です");
            throw new IllegalArgumentException("数量は必須です");
        }
        if (input.qty != null && input.qty < 1) {
            ui.onValidationError("qty", "数量は1以上です");
            throw new IllegalArgumentException("数量は1以上です");
        }
        if (input.qty != null && input.qty > 999999) {
            ui.onValidationError("qty", "数量は999999以下です");
            throw new IllegalArgumentException("数量は999999以下です");
        }
        // 備考
        if (input.note == null) input.note = "";
        if (input.note.length() > 200) {
            ui.onValidationError("note", "備考は200文字以内です");
            throw new IllegalArgumentException("備考は200文字以内です");
        }
    }

    public static final class Input {
        public String order_no;
        public Integer qty;
        public String note;
    }
}
